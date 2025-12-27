# Community Detection Guide

## Overview

GraphRAGにおけるコミュニティ検出は、Entityをクラスタリングし、Global Searchを可能にする重要な要素。

## Why Community Detection?

### Problem: Global Query

「最近の動向をまとめて」「主要なトピックは？」のような全体俯瞰クエリは、ベクトル検索の上位k件だけでは不十分。

### Solution: Community Summarization

Entityをコミュニティに分割し、各コミュニティの要約を生成。Global Searchではこの要約を検索・統合。

```
Query: "プロジェクトの主要な課題は？"
    │
    ▼
Community Reports から関連するものを選択
    │
    ▼
選択されたReportsを統合して回答生成
```

## Leiden Algorithm

### Why Leiden?

| Algorithm | Pros | Cons |
|-----------|------|------|
| Louvain | 高速 | 品質が不安定 |
| **Leiden** | 品質が安定、階層対応 | やや遅い |
| Label Propagation | 最速 | 品質が低い |

Leidenはグラフのコミュニティ構造を発見する最新のアルゴリズムで、Louvainの改良版。

### Key Features

- **Resolution parameter**: コミュニティの粒度を調整可能
- **Hierarchical**: 複数レベルの階層を生成
- **Well-connected**: コミュニティ内が十分に接続される保証

## Implementation Strategy

### Recommended: External Python

PostgreSQL内でのコミュニティ検出は複雑なため、外部Pythonで実行し結果をDBに格納する方式を推奨。

```python
import igraph as ig
import leidenalg as la
import psycopg2

def detect_communities(conn):
    # 1. グラフデータを取得
    edges_df = pd.read_sql("""
        SELECT src_entity_id, dst_entity_id, weight
        FROM edges
        WHERE confidence >= 0.7
    """, conn)

    entities_df = pd.read_sql("""
        SELECT id FROM entities
    """, conn)

    # 2. igraphグラフを構築
    g = ig.Graph.TupleList(
        edges_df[['src_entity_id', 'dst_entity_id']].itertuples(index=False),
        directed=False,
        weights=edges_df['weight'].tolist()
    )

    # 3. Leiden実行（階層的）
    partitions = []
    resolution = 1.0

    for level in range(3):  # 3階層
        partition = la.find_partition(
            g,
            la.RBConfigurationVertexPartition,
            resolution_parameter=resolution,
            weights='weight'
        )
        partitions.append(partition)
        resolution *= 0.5  # 上位階層は粗く

    # 4. 結果をDBに保存
    save_communities(conn, partitions)

    return partitions
```

### DB Schema for Communities

```sql
-- コミュニティ（階層構造）
CREATE TABLE communities (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    level           INT NOT NULL,
    parent_id       UUID REFERENCES communities(id),
    name            TEXT,
    metadata        JSONB DEFAULT '{}'::jsonb
);

-- Entity所属
CREATE TABLE community_entities (
    community_id    UUID REFERENCES communities(id) ON DELETE CASCADE,
    entity_id       UUID REFERENCES entities(id) ON DELETE CASCADE,
    PRIMARY KEY (community_id, entity_id)
);

-- コミュニティ要約
CREATE TABLE community_reports (
    community_id    UUID PRIMARY KEY REFERENCES communities(id),
    report          TEXT NOT NULL,
    embedding       vector(1536),
    model_id        TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);
```

### Python Implementation

```python
def save_communities(conn, partitions):
    cursor = conn.cursor()

    # レベルごとに保存
    parent_map = {}  # entity_id -> parent_community_id

    for level, partition in enumerate(partitions):
        for community_idx, members in enumerate(partition):
            # コミュニティを作成
            community_id = uuid.uuid4()

            # 親コミュニティを特定（上位レベルの場合）
            parent_id = None
            if level > 0:
                # メンバーの多数決で親を決定
                parent_counts = Counter(
                    parent_map.get(m) for m in members
                    if parent_map.get(m)
                )
                if parent_counts:
                    parent_id = parent_counts.most_common(1)[0][0]

            cursor.execute("""
                INSERT INTO communities (id, level, parent_id)
                VALUES (%s, %s, %s)
            """, (community_id, level, parent_id))

            # メンバーシップを保存
            for entity_id in members:
                cursor.execute("""
                    INSERT INTO community_entities (community_id, entity_id)
                    VALUES (%s, %s)
                """, (community_id, entity_id))
                parent_map[entity_id] = community_id

    conn.commit()
```

## Community Summarization

### Prompt Template

```markdown
# Community Summary Task

以下のコミュニティに含まれるエンティティと関係から、このコミュニティを要約してください。

## エンティティ
{entities_list}

## 関係
{edges_list}

## 出力形式

以下の形式で要約を生成してください:

1. **概要** (2-3文): このコミュニティが何を表しているか
2. **主要エンティティ**: 最も重要な3-5個のエンティティ
3. **主要な関係**: 最も重要な関係パターン
4. **キーワード**: 検索に使えるキーワード5-10個

---

## コミュニティデータ

{community_data}
```

### Summarization Flow

```python
async def generate_community_reports(conn):
    # 最下層コミュニティから処理
    for level in range(max_level + 1):
        communities = get_communities_at_level(conn, level)

        for community in communities:
            # コミュニティのメンバーと関係を取得
            members = get_community_members(conn, community.id)
            edges = get_community_edges(conn, community.id)

            # 下位コミュニティの要約も含める（上位レベルの場合）
            child_reports = []
            if level > 0:
                child_reports = get_child_reports(conn, community.id)

            # LLMで要約生成
            report = await generate_report(members, edges, child_reports)

            # Embeddingを生成
            embedding = await generate_embedding(report)

            # 保存
            save_report(conn, community.id, report, embedding)
```

## Hierarchical Structure

### Level Design

| Level | Resolution | Granularity | Use Case |
|-------|------------|-------------|----------|
| 0 | 1.0 | 細粒度 | 特定トピックの詳細 |
| 1 | 0.5 | 中粒度 | トピッククラスタ |
| 2 | 0.25 | 粗粒度 | 全体テーマ |

### Traversal

```sql
-- 特定コミュニティの階層を取得
WITH RECURSIVE community_tree AS (
    -- 起点コミュニティ
    SELECT id, level, parent_id, 0 as depth
    FROM communities
    WHERE id = $1

    UNION ALL

    -- 親を再帰的に取得
    SELECT c.id, c.level, c.parent_id, ct.depth + 1
    FROM communities c
    JOIN community_tree ct ON c.id = ct.parent_id
)
SELECT * FROM community_tree;
```

## Update Strategy

### When to Re-detect

- 新規Entityが全体の10%以上追加された
- 新規Edgeが全体の20%以上追加された
- 定期バッチ（週次/月次）

### Incremental Update

完全再計算は重いため、差分更新を検討:

```python
def incremental_update(conn, new_entities, new_edges):
    # 1. 影響を受けるコミュニティを特定
    affected = get_affected_communities(conn, new_entities, new_edges)

    # 2. 影響コミュニティのサブグラフを抽出
    subgraph = extract_subgraph(conn, affected)

    # 3. サブグラフのみ再クラスタリング
    new_partition = leiden(subgraph)

    # 4. 結果をマージ
    merge_partition(conn, affected, new_partition)

    # 5. 影響コミュニティの要約を再生成
    regenerate_reports(conn, affected)
```

## Query Integration

### Global Search with Communities

```sql
-- コミュニティ要約からGlobal Searchc
WITH relevant_communities AS (
    SELECT
        cr.community_id,
        cr.report,
        cr.embedding <=> $1 as distance
    FROM community_reports cr
    JOIN communities c ON cr.community_id = c.id
    WHERE c.level = 1  -- 中粒度レベル
    ORDER BY cr.embedding <=> $1
    LIMIT 5
)
SELECT
    rc.report,
    array_agg(DISTINCT e.name) as entities,
    rc.distance
FROM relevant_communities rc
JOIN community_entities ce ON rc.community_id = ce.community_id
JOIN entities e ON ce.entity_id = e.id
GROUP BY rc.community_id, rc.report, rc.distance
ORDER BY rc.distance;
```

## Best Practices

### 1. Resolution Tuning

```python
# 目安
# - 小規模（<1000 entities）: resolution = 1.0
# - 中規模（1000-10000）: resolution = 0.8
# - 大規模（>10000）: resolution = 0.5
```

### 2. Quality Check

```sql
-- コミュニティサイズの分布確認
SELECT level, COUNT(*) as num_communities,
       AVG(member_count) as avg_size,
       MIN(member_count) as min_size,
       MAX(member_count) as max_size
FROM (
    SELECT c.level, c.id, COUNT(ce.entity_id) as member_count
    FROM communities c
    LEFT JOIN community_entities ce ON c.id = ce.community_id
    GROUP BY c.level, c.id
) sub
GROUP BY level;
```

### 3. Orphan Handling

コミュニティに属さないEntityの処理:

```sql
-- 孤立Entityを特定
SELECT e.id, e.name
FROM entities e
LEFT JOIN community_entities ce ON e.id = ce.entity_id
WHERE ce.community_id IS NULL;

-- 最も近いコミュニティに割り当て
-- （Entity Embeddingとコミュニティ重心の類似度で）
```
