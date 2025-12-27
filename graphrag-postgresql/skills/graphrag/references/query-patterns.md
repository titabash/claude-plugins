# Query Patterns Guide

## Overview

GraphRAGの3つの検索パターン: Local Search、Global Search、Hybrid Search。

## Query Type Selection

```
┌─────────────────────────────────────────────────────────────┐
│                    Query Classification                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  "Xについて教えて"     → Local Search                        │
│  "Xの使い方は？"       → Local Search                        │
│  "XとYの関係は？"      → Local Search (multi-seed)           │
│                                                             │
│  "最近の動向は？"      → Global Search                       │
│  "主要なトピックは？"  → Global Search                       │
│  "全体をまとめて"      → Global Search                       │
│                                                             │
│  "Xに関連する問題"     → Hybrid Search                       │
│  "製品Aの不具合で..."  → Hybrid Search                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Local Search

### Concept

特定のEntityを起点に、グラフを展開して関連情報を収集。

```
Query: "PostgreSQLのパフォーマンスチューニングについて"
    │
    ▼
Entity Linking: "PostgreSQL" → entity_id
    │
    ▼
Graph Expansion: entity → 1-hop edges → related entities
    │
    ▼
Evidence Collection: entities → mentions → chunks
    │
    ▼
Response Generation
```

### SQL Implementation

```sql
-- Step 1: Entity Linking（クエリからEntityを特定）
WITH seed_entities AS (
    SELECT id, name, entity_type
    FROM entities
    WHERE name ILIKE '%PostgreSQL%'
       OR aliases && ARRAY['PostgreSQL', 'postgres', 'PG']
    LIMIT 5
),

-- Step 2: 1-hop Edge Expansion
related_edges AS (
    SELECT
        e.id as edge_id,
        e.src_entity_id,
        e.dst_entity_id,
        e.edge_type,
        e.weight,
        e.confidence,
        e.description as edge_description,
        CASE
            WHEN e.src_entity_id IN (SELECT id FROM seed_entities) THEN e.dst_entity_id
            ELSE e.src_entity_id
        END as related_entity_id
    FROM edges e
    WHERE (e.src_entity_id IN (SELECT id FROM seed_entities)
        OR e.dst_entity_id IN (SELECT id FROM seed_entities))
      AND e.confidence >= 0.7
),

-- Step 3: 関連Entityを取得
related_entities AS (
    SELECT DISTINCT
        ent.id,
        ent.name,
        ent.entity_type,
        ent.description
    FROM entities ent
    WHERE ent.id IN (SELECT related_entity_id FROM related_edges)
       OR ent.id IN (SELECT id FROM seed_entities)
),

-- Step 4: Evidence Chunks を取得
evidence_chunks AS (
    SELECT DISTINCT
        c.id,
        c.content,
        c.document_id,
        m.entity_id
    FROM chunks c
    JOIN mentions m ON c.id = m.chunk_id
    WHERE m.entity_id IN (SELECT id FROM related_entities)
)

-- Step 5: 結果を組み立て
SELECT
    re.name as entity_name,
    re.entity_type,
    re.description,
    array_agg(DISTINCT red.edge_type) as relations,
    array_agg(DISTINCT ec.content) as evidence
FROM related_entities re
LEFT JOIN related_edges red ON re.id = red.related_entity_id
LEFT JOIN evidence_chunks ec ON re.id = ec.entity_id
GROUP BY re.id, re.name, re.entity_type, re.description
ORDER BY COUNT(DISTINCT red.edge_id) DESC;
```

### N-hop Expansion

```sql
-- 2-hop展開
WITH RECURSIVE graph_expansion AS (
    -- 起点
    SELECT
        id as entity_id,
        0 as hop,
        ARRAY[id] as path
    FROM entities
    WHERE id = $seed_entity_id

    UNION ALL

    -- 再帰展開
    SELECT
        CASE
            WHEN e.src_entity_id = ge.entity_id THEN e.dst_entity_id
            ELSE e.src_entity_id
        END as entity_id,
        ge.hop + 1,
        ge.path || CASE
            WHEN e.src_entity_id = ge.entity_id THEN e.dst_entity_id
            ELSE e.src_entity_id
        END
    FROM graph_expansion ge
    JOIN edges e ON (e.src_entity_id = ge.entity_id OR e.dst_entity_id = ge.entity_id)
    WHERE ge.hop < 2  -- 最大2-hop
      AND NOT (CASE
          WHEN e.src_entity_id = ge.entity_id THEN e.dst_entity_id
          ELSE e.src_entity_id
      END = ANY(ge.path))  -- サイクル防止
      AND e.confidence >= 0.7
)
SELECT DISTINCT entity_id, MIN(hop) as min_hop
FROM graph_expansion
GROUP BY entity_id;
```

## Global Search

### Concept

コミュニティ要約を使用して、全体俯瞰的な質問に回答。

```
Query: "プロジェクトの主要な課題をまとめて"
    │
    ▼
Community Selection: クエリに関連するコミュニティを選択
    │
    ▼
Report Aggregation: 選択されたReportsを収集
    │
    ▼
Response Synthesis: Reportsを統合して回答生成
```

### SQL Implementation

```sql
-- Step 1: クエリEmbeddingで関連コミュニティを検索
WITH relevant_communities AS (
    SELECT
        cr.community_id,
        cr.report,
        c.level,
        cr.embedding <=> $query_embedding as distance
    FROM community_reports cr
    JOIN communities c ON cr.community_id = c.id
    WHERE c.level = 1  -- 中粒度レベルを優先
    ORDER BY cr.embedding <=> $query_embedding
    LIMIT 10
),

-- Step 2: コミュニティのメンバーEntity
community_members AS (
    SELECT
        rc.community_id,
        rc.report,
        rc.distance,
        array_agg(e.name ORDER BY e.name) as member_entities
    FROM relevant_communities rc
    JOIN community_entities ce ON rc.community_id = ce.community_id
    JOIN entities e ON ce.entity_id = e.id
    GROUP BY rc.community_id, rc.report, rc.distance
)

-- Step 3: 結果返却
SELECT
    report,
    member_entities,
    distance
FROM community_members
ORDER BY distance
LIMIT 5;
```

### Hierarchical Global Search

```sql
-- 上位レベルから下位レベルへドリルダウン
WITH top_level AS (
    SELECT
        cr.community_id,
        cr.report,
        c.level
    FROM community_reports cr
    JOIN communities c ON cr.community_id = c.id
    WHERE c.level = 2  -- 最上位レベル
    ORDER BY cr.embedding <=> $query_embedding
    LIMIT 3
),
child_communities AS (
    SELECT
        cr.community_id,
        cr.report,
        c.level,
        c.parent_id
    FROM community_reports cr
    JOIN communities c ON cr.community_id = c.id
    WHERE c.parent_id IN (SELECT community_id FROM top_level)
)
SELECT * FROM top_level
UNION ALL
SELECT community_id, report, level, NULL as parent_id FROM child_communities;
```

## Hybrid Search

### Concept

PGroonga（レキシカル）+ pgvector（セマンティック）を統合。

```
Query: "PostgreSQLのインデックス最適化"
    │
    ├──→ PGroonga: "PostgreSQL" "インデックス" "最適化"
    │         │
    │         ▼
    │     Lexical Results (固有名詞に強い)
    │
    └──→ pgvector: query_embedding
              │
              ▼
          Semantic Results (意味理解に強い)
              │
              ▼
          RRF Fusion
              │
              ▼
          Final Results
```

### SQL Implementation

```sql
-- Hybrid Search with RRF (Reciprocal Rank Fusion)
WITH
-- Lexical Search (PGroonga)
lexical_results AS (
    SELECT
        c.id as chunk_id,
        c.content,
        c.document_id,
        pgroonga_score(tableoid, ctid) as lex_score,
        ROW_NUMBER() OVER (ORDER BY pgroonga_score(tableoid, ctid) DESC) as lex_rank
    FROM chunks c
    WHERE c.content &@~ $query_text
    LIMIT 100
),

-- Semantic Search (pgvector)
semantic_results AS (
    SELECT
        ce.chunk_id,
        c.content,
        c.document_id,
        1 - (ce.embedding <=> $query_embedding) as sem_score,
        ROW_NUMBER() OVER (ORDER BY ce.embedding <=> $query_embedding) as sem_rank
    FROM chunk_embeddings ce
    JOIN chunks c ON ce.chunk_id = c.id
    ORDER BY ce.embedding <=> $query_embedding
    LIMIT 100
),

-- RRF Fusion
rrf_combined AS (
    SELECT
        COALESCE(lr.chunk_id, sr.chunk_id) as chunk_id,
        COALESCE(lr.content, sr.content) as content,
        COALESCE(lr.document_id, sr.document_id) as document_id,
        -- RRF Score: 1/(k+rank)、k=60が一般的
        COALESCE(1.0 / (60 + lr.lex_rank), 0) +
        COALESCE(1.0 / (60 + sr.sem_rank), 0) as rrf_score,
        lr.lex_rank,
        sr.sem_rank
    FROM lexical_results lr
    FULL OUTER JOIN semantic_results sr ON lr.chunk_id = sr.chunk_id
)

SELECT
    chunk_id,
    content,
    document_id,
    rrf_score,
    lex_rank,
    sem_rank
FROM rrf_combined
ORDER BY rrf_score DESC
LIMIT 20;
```

### Weighted RRF

```sql
-- 重み付きRRF（lexical:semantic = 0.4:0.6）
SELECT
    chunk_id,
    content,
    0.4 * COALESCE(1.0 / (60 + lex_rank), 0) +
    0.6 * COALESCE(1.0 / (60 + sem_rank), 0) as weighted_rrf_score
FROM rrf_combined
ORDER BY weighted_rrf_score DESC;
```

## Time-Sliced Query

### Query at Specific Point

```sql
-- 特定時点での関係を取得
WITH valid_edges AS (
    SELECT e.*
    FROM edges e
    LEFT JOIN events e_from ON e.valid_from_event_id = e_from.id
    LEFT JOIN events e_to ON e.valid_to_event_id = e_to.id
    WHERE (e.valid_from_event_id IS NULL OR e_from.event_index <= $as_of_event_index)
      AND (e.valid_to_event_id IS NULL OR e_to.event_index > $as_of_event_index)
)
SELECT * FROM valid_edges;
```

### Spoiler Control (Story)

```sql
-- ネタバレ制御（指定した話数まで）
SELECT c.*
FROM chunks c
WHERE (c.metadata->>'chapter')::int <= $max_chapter
  OR c.metadata->>'spoiler_level' IS NULL;
```

## Query Optimization

### Index Usage

```sql
-- EXPLAIN ANALYZEで確認
EXPLAIN ANALYZE
SELECT * FROM chunk_embeddings
WHERE embedding <=> $query_embedding < 0.5
ORDER BY embedding <=> $query_embedding
LIMIT 20;
```

### Filter Pushdown

```sql
-- フィルタを先にかける（効率化）
WITH filtered_chunks AS (
    SELECT id FROM chunks
    WHERE metadata->>'category' = 'tech'
)
SELECT ce.*, c.content
FROM chunk_embeddings ce
JOIN chunks c ON ce.chunk_id = c.id
WHERE ce.chunk_id IN (SELECT id FROM filtered_chunks)
ORDER BY ce.embedding <=> $query_embedding
LIMIT 20;
```

### Precomputed Views

```sql
-- 頻出クエリパターン用のマテリアライズドビュー
CREATE MATERIALIZED VIEW mv_entity_with_edges AS
SELECT
    e.id,
    e.name,
    e.entity_type,
    COUNT(DISTINCT ed.id) as edge_count,
    array_agg(DISTINCT ed.edge_type) as edge_types
FROM entities e
LEFT JOIN edges ed ON e.id = ed.src_entity_id OR e.id = ed.dst_entity_id
WHERE ed.confidence >= 0.7
GROUP BY e.id;

-- 定期リフレッシュ
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_entity_with_edges;
```

## Response Generation

### Context Assembly

```python
def assemble_context(local_results, global_results, hybrid_results):
    """
    検索結果からLLMに渡すコンテキストを組み立て
    """
    context_parts = []

    # Local Search結果（Entity中心）
    if local_results:
        context_parts.append("## 関連エンティティ")
        for entity in local_results.entities:
            context_parts.append(f"- {entity.name} ({entity.type}): {entity.description}")

        context_parts.append("\n## 関係")
        for edge in local_results.edges:
            context_parts.append(f"- {edge.src} --[{edge.type}]--> {edge.dst}")

    # Global Search結果（要約中心）
    if global_results:
        context_parts.append("\n## 全体概要")
        for report in global_results.reports:
            context_parts.append(f"### {report.community_name}")
            context_parts.append(report.summary)

    # Hybrid Search結果（Evidence中心）
    if hybrid_results:
        context_parts.append("\n## 参考情報")
        for chunk in hybrid_results.chunks:
            context_parts.append(f"[{chunk.source}]")
            context_parts.append(chunk.content)

    return "\n".join(context_parts)
```

### Citation Format

```python
def format_with_citations(response, evidence_chunks):
    """
    回答に引用を付与
    """
    # 各チャンクにIDを付与
    citations = {}
    for i, chunk in enumerate(evidence_chunks):
        citation_id = f"[{i+1}]"
        citations[citation_id] = {
            "source": chunk.document.title,
            "content": chunk.content[:200] + "..."
        }

    # 回答末尾に引用一覧を追加
    citation_list = "\n\n---\n**参考文献:**\n"
    for cid, info in citations.items():
        citation_list += f"{cid} {info['source']}\n"

    return response + citation_list
```
