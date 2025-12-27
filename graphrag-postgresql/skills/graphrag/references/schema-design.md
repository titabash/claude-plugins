# Schema Design Guide

## Overview

GraphRAGのPostgreSQLスキーマ設計ガイド。3レイヤー構造に基づくテーブル設計。

## Required Extensions

```sql
-- Vector search
CREATE EXTENSION IF NOT EXISTS vector;

-- Japanese full-text search
CREATE EXTENSION IF NOT EXISTS pgroonga;

-- UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

## Core Tables

### 1. documents（文書）

元文書のメタデータを管理。

```sql
CREATE TABLE documents (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_id       TEXT NOT NULL,              -- 外部システムでの識別子
    title           TEXT,
    content_type    TEXT NOT NULL,              -- text/plain, text/markdown, etc.
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,

    UNIQUE(source_id)
);

COMMENT ON TABLE documents IS '元文書のメタデータ';
COMMENT ON COLUMN documents.source_id IS '外部システムでの一意識別子（ファイルパス、URL等）';
COMMENT ON COLUMN documents.metadata IS '任意のメタデータ（author, version, tags等）';
```

**metadata例**:
```json
{
  "author": "John Doe",
  "version": "1.2.0",
  "tags": ["api", "reference"],
  "language": "ja"
}
```

### 2. chunks（テキスト断片）

文書を分割したChunk。

```sql
CREATE TABLE chunks (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id     UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    chunk_index     INT NOT NULL,               -- 文書内での順序
    content         TEXT NOT NULL,
    token_count     INT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,

    UNIQUE(document_id, chunk_index)
);

COMMENT ON TABLE chunks IS '文書を分割したテキスト断片';
COMMENT ON COLUMN chunks.chunk_index IS '文書内での順序（0-indexed）';
COMMENT ON COLUMN chunks.token_count IS 'トークン数（embedding model依存）';
```

**metadata例**:
```json
{
  "chapter": "第3章",
  "section": "3.2",
  "page": 42,
  "spoiler_level": 3
}
```

### 3. chunk_embeddings（Chunkベクトル）

Chunkのベクトル表現。

```sql
CREATE TABLE chunk_embeddings (
    chunk_id        UUID PRIMARY KEY REFERENCES chunks(id) ON DELETE CASCADE,
    embedding       vector(1536) NOT NULL,      -- dimension は model 依存
    model_id        TEXT NOT NULL,              -- embedding model 識別子
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE chunk_embeddings IS 'Chunkのベクトル表現';
COMMENT ON COLUMN chunk_embeddings.model_id IS 'text-embedding-3-small 等';
```

### 4. entities（エンティティ）

抽出された概念・登場要素。

```sql
CREATE TABLE entities (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            TEXT NOT NULL,              -- 正規名
    entity_type     TEXT NOT NULL,              -- Person, Location, Concept, etc.
    aliases         TEXT[] DEFAULT '{}',        -- 別名・表記揺れ
    description     TEXT,                       -- エンティティの説明
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,

    UNIQUE(name, entity_type)
);

COMMENT ON TABLE entities IS '抽出された概念・登場要素';
COMMENT ON COLUMN entities.aliases IS '別名、表記揺れ、略称等';
```

**entity_type例**:
- `Person`: 人物、キャラクター
- `Organization`: 組織、会社
- `Location`: 場所、地名
- `Product`: 製品、サービス
- `Concept`: 概念、用語
- `Event`: 出来事、イベント
- `Technology`: 技術、ツール

### 5. entity_embeddings（Entityベクトル）

Entityのベクトル表現（オプション）。

```sql
CREATE TABLE entity_embeddings (
    entity_id       UUID PRIMARY KEY REFERENCES entities(id) ON DELETE CASCADE,
    embedding       vector(1536) NOT NULL,
    model_id        TEXT NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE entity_embeddings IS 'Entityのベクトル表現（Entity Linkingに使用）';
```

### 6. edges（関係）

Entity間の関係。

```sql
CREATE TABLE edges (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    src_entity_id       UUID NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    dst_entity_id       UUID NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    edge_type           TEXT NOT NULL,          -- works_at, depends_on, etc.
    weight              REAL NOT NULL DEFAULT 1.0,
    confidence          REAL NOT NULL DEFAULT 1.0,  -- 抽出信頼度
    description         TEXT,                   -- 関係の説明
    evidence_chunk_id   UUID REFERENCES chunks(id) ON DELETE SET NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata            JSONB NOT NULL DEFAULT '{}'::jsonb
);

COMMENT ON TABLE edges IS 'Entity間の関係';
COMMENT ON COLUMN edges.weight IS '関係の強さ（頻度、重要度）';
COMMENT ON COLUMN edges.confidence IS 'LLM抽出時の信頼度';
COMMENT ON COLUMN edges.evidence_chunk_id IS '根拠となるChunk';
```

**edge_type例**:
- `works_at`: 所属
- `friend_of`, `enemy_of`: 人間関係
- `depends_on`: 依存関係
- `causes`, `caused_by`: 因果関係
- `part_of`: 構成関係
- `located_in`: 場所関係

### 7. mentions（出現）

Chunk内でのEntity出現。

```sql
CREATE TABLE mentions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    chunk_id        UUID NOT NULL REFERENCES chunks(id) ON DELETE CASCADE,
    entity_id       UUID NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    span_start      INT,                        -- 文字位置（開始）
    span_end        INT,                        -- 文字位置（終了）
    confidence      REAL NOT NULL DEFAULT 1.0,

    UNIQUE(chunk_id, entity_id, span_start)
);

COMMENT ON TABLE mentions IS 'Chunk内でのEntity出現';
```

## Extension Tables

### 8. events（イベント・時間軸）

時系列を管理するためのイベントテーブル。

```sql
CREATE TABLE events (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id     UUID REFERENCES documents(id) ON DELETE CASCADE,
    event_index     INT NOT NULL,               -- 単調増加の順序
    name            TEXT NOT NULL,
    ref             TEXT,                       -- 章番号、話数等
    occurred_at     TIMESTAMPTZ,                -- 実時間（あれば）
    metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,

    UNIQUE(document_id, event_index)
);

COMMENT ON TABLE events IS '時系列管理用のイベント';
COMMENT ON COLUMN events.event_index IS '物語内の順序（章、話数など）';
```

### 9. edge_validity（関係の時間軸）

関係の有効期間を管理。

```sql
ALTER TABLE edges ADD COLUMN valid_from_event_id UUID REFERENCES events(id);
ALTER TABLE edges ADD COLUMN valid_to_event_id UUID REFERENCES events(id);

COMMENT ON COLUMN edges.valid_from_event_id IS 'この関係が有効になったイベント';
COMMENT ON COLUMN edges.valid_to_event_id IS 'この関係が無効になったイベント（NULLは現在も有効）';
```

### 10. communities（コミュニティ）

Entity のクラスタ（階層構造）。

```sql
CREATE TABLE communities (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    level           INT NOT NULL,               -- 0=leaf, 高いほど抽象
    parent_id       UUID REFERENCES communities(id) ON DELETE SET NULL,
    name            TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata        JSONB NOT NULL DEFAULT '{}'::jsonb
);

COMMENT ON TABLE communities IS 'Entityのクラスタ（階層構造）';
COMMENT ON COLUMN communities.level IS '0が最下層、上位ほど抽象度が高い';
```

### 11. community_entities（コミュニティ所属）

EntityとCommunityの多対多関係。

```sql
CREATE TABLE community_entities (
    community_id    UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
    entity_id       UUID NOT NULL REFERENCES entities(id) ON DELETE CASCADE,

    PRIMARY KEY (community_id, entity_id)
);

COMMENT ON TABLE community_entities IS 'EntityのCommunity所属';
```

### 12. community_reports（コミュニティ要約）

Global Searchで使用する要約。

```sql
CREATE TABLE community_reports (
    community_id    UUID PRIMARY KEY REFERENCES communities(id) ON DELETE CASCADE,
    report          TEXT NOT NULL,
    embedding       vector(1536),               -- 要約のベクトル
    model_id        TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata        JSONB NOT NULL DEFAULT '{}'::jsonb
);

COMMENT ON TABLE community_reports IS 'コミュニティの要約（Global Search用）';
```

## ER Diagram

```
documents ─────1:N────→ chunks ─────1:1────→ chunk_embeddings
    │                      │
    │                      │
    1:N                   N:M
    │                      │
    ▼                      ▼
 events               mentions
                          │
                          │
                         N:M
                          │
                          ▼
                      entities ─────1:1────→ entity_embeddings
                          │
                         N:M
                          │
                          ▼
                        edges ◄──────────────── evidence_chunk_id
                          │
                          │
                       valid_from/to
                          │
                          ▼
                       events

communities ◄── parent_id (self-reference)
    │
   1:N
    │
    ▼
community_entities ◄────N:M────► entities
    │
    1:1
    │
    ▼
community_reports
```

## Best Practices

### 1. source_id の設計
- 必ず一意に識別可能な値を設定
- 外部システムとの連携を考慮
- 例: `file:///path/to/doc.md`, `notion://page/xxx`

### 2. metadata の活用
- スキーマ変更なしで拡張可能
- クエリ時の追加フィルタに使用
- GINインデックスで高速検索

### 3. confidence の扱い
- LLM抽出時の信頼度を記録
- 低confidenceのedgeはデフォルト除外
- 段階的にthresholdを下げて検索拡張

### 4. 時間軸の設計
- 物語系: `event_index` で章/話順序
- 技術系: `occurred_at` で実時間
- 両方必要な場合は両方使用
