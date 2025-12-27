# Indexing Strategies

## Overview

pgvector + PGroonga によるインデックス戦略。検索性能とストレージのトレードオフを考慮した設計。

## pgvector Indexes

### HNSW (Hierarchical Navigable Small World)

**推奨**: 初期導入、バランス重視

```sql
CREATE INDEX idx_chunk_embeddings_hnsw
ON chunk_embeddings USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);
```

**パラメータ**:
| Parameter | Default | Description |
|-----------|---------|-------------|
| `m` | 16 | ノードあたりの接続数（高い=精度↑、メモリ↑） |
| `ef_construction` | 64 | 構築時の探索幅（高い=精度↑、構築時間↑） |

**特徴**:
- 検索時の精度が高い（recall 95%+）
- インデックス構築は遅い
- メモリ使用量が多い
- 挿入は比較的高速

**用途**:
- 本番環境の主要インデックス
- 精度が重要なユースケース

### IVFFlat (Inverted File with Flat)

**推奨**: 大規模データ、メモリ制約あり

```sql
CREATE INDEX idx_chunk_embeddings_ivfflat
ON chunk_embeddings USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);
```

**パラメータ**:
| Parameter | Recommendation | Description |
|-----------|----------------|-------------|
| `lists` | rows/1000 (最大で sqrt(rows)) | クラスタ数 |

**特徴**:
- 構築が高速
- メモリ効率が良い
- 検索時にprobesでrecall調整可能
- データ分布に依存

**用途**:
- 100万行以上の大規模データ
- メモリ制約のある環境
- 頻繁な再構築が必要な場合

### 距離演算子

| Operator | Index Ops | Description |
|----------|-----------|-------------|
| `<->` | `vector_l2_ops` | L2距離（ユークリッド） |
| `<=>` | `vector_cosine_ops` | コサイン距離 |
| `<#>` | `vector_ip_ops` | 内積（負値） |

**推奨**: `vector_cosine_ops`（正規化不要、直感的）

### 検索時の設定

```sql
-- HNSW: 検索時の探索幅
SET hnsw.ef_search = 100;  -- default: 40

-- IVFFlat: 検索時のクラスタ数
SET ivfflat.probes = 10;   -- default: 1
```

## PGroonga Indexes

### 基本設定

```sql
CREATE INDEX idx_chunks_content_pgroonga
ON chunks USING pgroonga (content)
WITH (tokenizer = 'TokenMecab');
```

### Tokenizer選択

| Tokenizer | 用途 |
|-----------|------|
| `TokenMecab` | 日本語（推奨） |
| `TokenBigram` | 汎用（部分一致） |
| `TokenNgram` | 完全一致重視 |
| `TokenRegexp` | 正規表現 |

### 日本語向け最適化

```sql
-- MeCab辞書でのTokenizer
CREATE INDEX idx_chunks_content_pgroonga
ON chunks USING pgroonga (content)
WITH (
    tokenizer = 'TokenMecab',
    normalizer = 'NormalizerNFKC130'
);

-- 別名検索用（Entity）
CREATE INDEX idx_entities_name_pgroonga
ON entities USING pgroonga (name);

CREATE INDEX idx_entities_aliases_pgroonga
ON entities USING pgroonga (aliases)
WITH (tokenizer = 'TokenMecab');
```

### 検索演算子

```sql
-- 全文検索
SELECT * FROM chunks WHERE content &@~ 'キーワード';

-- フレーズ検索
SELECT * FROM chunks WHERE content &@~ '"exact phrase"';

-- AND/OR
SELECT * FROM chunks WHERE content &@~ 'keyword1 OR keyword2';
```

## B-tree Indexes

### 必須インデックス

```sql
-- Entity参照用
CREATE INDEX idx_edges_src ON edges(src_entity_id);
CREATE INDEX idx_edges_dst ON edges(dst_entity_id);
CREATE INDEX idx_edges_type ON edges(edge_type);

-- 時間軸クエリ用
CREATE INDEX idx_edges_valid_from ON edges(valid_from_event_id);
CREATE INDEX idx_edges_valid_to ON edges(valid_to_event_id);

-- Mention参照用
CREATE INDEX idx_mentions_chunk ON mentions(chunk_id);
CREATE INDEX idx_mentions_entity ON mentions(entity_id);

-- Event順序用
CREATE INDEX idx_events_order ON events(document_id, event_index);
```

### JSONB GINインデックス

```sql
-- メタデータ検索用
CREATE INDEX idx_documents_metadata ON documents USING gin (metadata);
CREATE INDEX idx_chunks_metadata ON chunks USING gin (metadata);
CREATE INDEX idx_entities_metadata ON entities USING gin (metadata);
```

## Filtered Search (iterative_scan)

### 問題: Overfiltering

ANNで取得後にフィルタすると、結果が不足する問題。

```sql
-- 悪い例: ANNで100件→フィルタで10件になる
SELECT * FROM chunk_embeddings ce
JOIN chunks c ON ce.chunk_id = c.id
WHERE c.metadata->>'category' = 'tech'
ORDER BY ce.embedding <=> $1
LIMIT 20;
```

### 解決: iterative_scan (pgvector 0.8.0+)

```sql
-- iterative_scan を有効化
SET hnsw.iterative_scan = relaxed_order;

-- フィルタ付きでも結果が保証される
SELECT * FROM chunk_embeddings ce
JOIN chunks c ON ce.chunk_id = c.id
WHERE c.metadata->>'category' = 'tech'
ORDER BY ce.embedding <=> $1
LIMIT 20;
```

**モード**:
| Mode | Description |
|------|-------------|
| `off` | 従来の動作 |
| `relaxed_order` | 順序を緩和して結果を保証 |
| `strict_order` | 順序を維持しつつ結果を保証 |

### 部分インデックス

特定条件での検索が多い場合:

```sql
-- カテゴリ別の部分インデックス
CREATE INDEX idx_chunk_embeddings_tech
ON chunk_embeddings USING hnsw (embedding vector_cosine_ops)
WHERE chunk_id IN (
    SELECT id FROM chunks WHERE metadata->>'category' = 'tech'
);
```

## Performance Tuning

### メモリ設定

```sql
-- 共有メモリ
SET shared_buffers = '4GB';  -- RAM の 25%

-- 作業メモリ
SET work_mem = '256MB';  -- ソート、ハッシュ用

-- メンテナンス用
SET maintenance_work_mem = '1GB';  -- インデックス構築用
```

### 並列処理

```sql
SET max_parallel_workers_per_gather = 4;
SET parallel_tuple_cost = 0.001;
SET parallel_setup_cost = 100;
```

### インデックス構築

```sql
-- 並列構築（PostgreSQL 15+）
SET max_parallel_maintenance_workers = 4;

-- 大量データ投入時はインデックスを後から作成
DROP INDEX IF EXISTS idx_chunk_embeddings_hnsw;
-- ... データ投入 ...
CREATE INDEX CONCURRENTLY idx_chunk_embeddings_hnsw ...
```

## Monitoring

### インデックス使用状況

```sql
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE tablename IN ('chunk_embeddings', 'chunks', 'entities', 'edges');
```

### インデックスサイズ

```sql
SELECT
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as size
FROM pg_indexes
WHERE tablename = 'chunk_embeddings';
```

## Best Practices

### 1. インデックス選択フロー

```
データ量 < 10万行?
  → インデックスなし or IVFFlat

精度最優先?
  → HNSW (m=24, ef_construction=100)

メモリ制約あり?
  → IVFFlat

フィルタクエリが多い?
  → iterative_scan + 部分インデックス
```

### 2. 初期推奨設定

```sql
-- HNSW（標準）
CREATE INDEX idx_chunk_embeddings_hnsw
ON chunk_embeddings USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

-- PGroonga（日本語）
CREATE INDEX idx_chunks_content_pgroonga
ON chunks USING pgroonga (content)
WITH (tokenizer = 'TokenMecab');

-- iterative_scan有効化
SET hnsw.iterative_scan = relaxed_order;
```

### 3. 定期メンテナンス

```sql
-- 統計情報更新
ANALYZE chunk_embeddings;
ANALYZE chunks;
ANALYZE entities;
ANALYZE edges;

-- インデックス再構築（断片化対策）
REINDEX INDEX CONCURRENTLY idx_chunk_embeddings_hnsw;
```
