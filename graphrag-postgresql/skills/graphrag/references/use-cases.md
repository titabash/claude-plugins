# Use Cases Guide

## Overview

ユースケース別のEntity/Edge型定義と設計パターン。

## 1. Story/Content（物語・コンテンツ）

小説、マンガ、ゲームシナリオなどのキャラクター関係管理。

### Entity Types

| Type | Description | Examples |
|------|-------------|----------|
| Character | 登場人物 | 主人公、ヒロイン、敵役 |
| Organization | 組織・団体 | 王国、ギルド、会社 |
| Location | 場所 | 城、森、異世界の地名 |
| Item | アイテム・道具 | 武器、魔法道具、重要アイテム |
| Ability | 能力・スキル | 魔法、特殊能力 |
| Event | 出来事 | 戦い、事件、イベント |
| Concept | 設定・概念 | 魔法体系、世界観設定 |

### Edge Types

```
Character Relations:
├── friend_of        # 友人関係
├── enemy_of         # 敵対関係
├── ally_of          # 同盟関係
├── betrayed         # 裏切り
├── family_of        # 家族関係
├── mentor_of        # 師弟関係
├── loves            # 恋愛関係
└── subordinate_of   # 上下関係

Possession/Ability:
├── possesses        # 所有（Item）
├── uses             # 使用（Ability）
└── masters          # 習得

Location:
├── lives_in         # 居住
├── rules            # 支配
└── visited          # 訪問

Event:
├── participates_in  # 参加
├── causes           # 引き起こす
└── affected_by      # 影響を受ける
```

### Schema Example

```sql
-- 物語向けEntity型
INSERT INTO entity_types (name, description) VALUES
('Character', '登場人物'),
('Organization', '組織・団体'),
('Location', '場所'),
('Item', 'アイテム'),
('Ability', '能力'),
('Event', '出来事');

-- 物語向けEdge型
INSERT INTO edge_types (name, directed, description) VALUES
('friend_of', false, '友人関係'),
('enemy_of', false, '敵対関係'),
('ally_of', false, '同盟関係'),
('betrayed', true, '裏切り（A→Bを裏切った）'),
('family_of', false, '家族関係'),
('mentor_of', true, '師弟関係（A→BはAがBの師匠）'),
('loves', true, '恋愛感情'),
('possesses', true, '所有'),
('participates_in', true, 'イベント参加');
```

### Query Examples

```sql
-- キャラクターの全関係を取得
SELECT
    e1.name as character,
    ed.edge_type,
    e2.name as related_to,
    ev.name as valid_until_event
FROM entities e1
JOIN edges ed ON e1.id = ed.src_entity_id
JOIN entities e2 ON ed.dst_entity_id = e2.id
LEFT JOIN events ev ON ed.valid_to_event_id = ev.id
WHERE e1.name = '主人公名'
  AND e1.entity_type = 'Character'
ORDER BY ed.edge_type;

-- 特定時点での同盟関係
SELECT e1.name, e2.name
FROM edges ed
JOIN entities e1 ON ed.src_entity_id = e1.id
JOIN entities e2 ON ed.dst_entity_id = e2.id
JOIN events ev_from ON ed.valid_from_event_id = ev_from.id
LEFT JOIN events ev_to ON ed.valid_to_event_id = ev_to.id
WHERE ed.edge_type = 'ally_of'
  AND ev_from.event_index <= $as_of_chapter
  AND (ev_to IS NULL OR ev_to.event_index > $as_of_chapter);
```

## 2. Technical Documentation（技術文書）

API仕様書、設計書、開発ガイドなど。

### Entity Types

| Type | Description | Examples |
|------|-------------|----------|
| Technology | 技術・言語 | Python, PostgreSQL, React |
| Product | 製品・サービス | AWS, GCP, GitHub |
| API | API・エンドポイント | REST API, GraphQL |
| Component | コンポーネント | モジュール、クラス |
| Concept | 概念・パターン | マイクロサービス、CQRS |
| Person | 人物 | 著者、メンテナー |
| Organization | 組織 | 会社、OSSコミュニティ |

### Edge Types

```
Dependency:
├── depends_on       # 依存関係
├── extends          # 継承・拡張
├── implements       # 実装
├── uses             # 使用
└── requires         # 必要条件

Compatibility:
├── compatible_with  # 互換性あり
├── alternative_to   # 代替
└── replaces         # 置き換え

Documentation:
├── documents        # 文書化
├── examples         # 例示
└── references       # 参照
```

### Schema Example

```sql
-- 技術文書向けEntity型
INSERT INTO entity_types (name, description) VALUES
('Technology', '技術・言語・フレームワーク'),
('Product', '製品・サービス'),
('API', 'API・エンドポイント'),
('Component', 'コンポーネント・モジュール'),
('Concept', '概念・パターン'),
('Version', 'バージョン');

-- 技術文書向けEdge型
INSERT INTO edge_types (name, directed, description) VALUES
('depends_on', true, '依存関係'),
('extends', true, '継承・拡張'),
('implements', true, '実装'),
('compatible_with', false, '互換性'),
('alternative_to', false, '代替'),
('deprecated_by', true, '非推奨（後継）');
```

### Query Examples

```sql
-- 依存関係ツリー
WITH RECURSIVE dep_tree AS (
    SELECT
        e.id,
        e.name,
        0 as depth,
        ARRAY[e.name] as path
    FROM entities e
    WHERE e.name = 'TargetLibrary'

    UNION ALL

    SELECT
        e2.id,
        e2.name,
        dt.depth + 1,
        dt.path || e2.name
    FROM dep_tree dt
    JOIN edges ed ON ed.src_entity_id = dt.id
    JOIN entities e2 ON ed.dst_entity_id = e2.id
    WHERE ed.edge_type = 'depends_on'
      AND dt.depth < 5
      AND NOT e2.name = ANY(dt.path)
)
SELECT * FROM dep_tree ORDER BY depth, name;

-- 代替技術の検索
SELECT
    e1.name as technology,
    e2.name as alternative,
    ed.description as reason
FROM edges ed
JOIN entities e1 ON ed.src_entity_id = e1.id
JOIN entities e2 ON ed.dst_entity_id = e2.id
WHERE ed.edge_type = 'alternative_to';
```

## 3. Knowledge Base（ナレッジベース）

社内Wiki、FAQ、手順書など。

### Entity Types

| Type | Description | Examples |
|------|-------------|----------|
| Concept | 用語・定義 | KPI、SLA、ポリシー |
| Process | 手順・ワークフロー | 申請フロー、承認プロセス |
| Role | 役割・担当 | 管理者、承認者 |
| Document | 文書・規定 | 規則、マニュアル |
| System | システム | 社内ツール、基幹システム |
| Department | 部署・チーム | 営業部、開発チーム |

### Edge Types

```
Definition:
├── defines          # 定義
├── includes         # 包含
└── excludes         # 除外

Process:
├── precedes         # 先行（手順順序）
├── requires         # 必要条件
├── approves         # 承認
└── escalates_to     # エスカレーション

Reference:
├── references       # 参照
├── supersedes       # 置き換え
└── related_to       # 関連
```

### Schema Example

```sql
-- ナレッジベース向けEntity型
INSERT INTO entity_types (name, description) VALUES
('Concept', '用語・定義'),
('Process', '手順・ワークフロー'),
('Role', '役割・担当'),
('Document', '文書・規定'),
('System', 'システム・ツール'),
('Department', '部署・チーム');

-- ナレッジベース向けEdge型
INSERT INTO edge_types (name, directed, description) VALUES
('defines', true, '定義'),
('precedes', true, '先行（順序）'),
('requires', true, '必要条件'),
('approves', true, '承認関係'),
('supersedes', true, '置き換え'),
('references', true, '参照');
```

### Query Examples

```sql
-- 手順の順序を取得
WITH RECURSIVE process_flow AS (
    SELECT
        e.id,
        e.name,
        1 as step_order,
        ARRAY[e.id] as visited
    FROM entities e
    WHERE e.name = '申請開始'
      AND e.entity_type = 'Process'

    UNION ALL

    SELECT
        e2.id,
        e2.name,
        pf.step_order + 1,
        pf.visited || e2.id
    FROM process_flow pf
    JOIN edges ed ON ed.src_entity_id = pf.id
    JOIN entities e2 ON ed.dst_entity_id = e2.id
    WHERE ed.edge_type = 'precedes'
      AND NOT e2.id = ANY(pf.visited)
)
SELECT step_order, name FROM process_flow ORDER BY step_order;

-- 用語の定義と関連文書
SELECT
    e.name as term,
    e.description as definition,
    array_agg(DISTINCT doc.name) as related_documents
FROM entities e
LEFT JOIN edges ed ON e.id = ed.src_entity_id AND ed.edge_type = 'references'
LEFT JOIN entities doc ON ed.dst_entity_id = doc.id AND doc.entity_type = 'Document'
WHERE e.entity_type = 'Concept'
GROUP BY e.id, e.name, e.description;
```

## 4. Incident/Troubleshooting（障害・トラブル）

障害報告、原因分析、解決策など。

### Entity Types

| Type | Description | Examples |
|------|-------------|----------|
| Symptom | 症状・エラー | タイムアウト、500エラー |
| Cause | 原因 | メモリリーク、設定ミス |
| Solution | 解決策 | パッチ適用、設定変更 |
| Workaround | 回避策 | 一時対応、代替手順 |
| Component | コンポーネント | DBサーバー、APIゲートウェイ |
| Incident | インシデント | 障害イベント |

### Edge Types

```
Causality:
├── causes           # 原因（Cause → Symptom）
├── caused_by        # 被原因（Symptom → Cause）
├── leads_to         # 連鎖（Symptom → Symptom）

Resolution:
├── solved_by        # 解決（Symptom → Solution）
├── workaround_for   # 回避策（Workaround → Symptom）
├── prevents         # 予防（Solution → Cause）

Scope:
├── affects          # 影響（Cause → Component）
├── occurred_in      # 発生場所
└── related_to       # 関連
```

### Schema Example

```sql
-- 障害向けEntity型
INSERT INTO entity_types (name, description) VALUES
('Symptom', '症状・エラー'),
('Cause', '原因'),
('Solution', '解決策'),
('Workaround', '回避策'),
('Component', 'コンポーネント'),
('Incident', 'インシデント');

-- 障害向けEdge型
INSERT INTO edge_types (name, directed, description) VALUES
('causes', true, '原因（A→BはAがBを引き起こす）'),
('caused_by', true, '被原因'),
('solved_by', true, '解決'),
('workaround_for', true, '回避策'),
('affects', true, '影響'),
('prevents', true, '予防');
```

### Query Examples

```sql
-- 症状から原因と解決策を検索
WITH symptom_analysis AS (
    SELECT
        sym.id as symptom_id,
        sym.name as symptom,
        cause.name as root_cause,
        sol.name as solution
    FROM entities sym
    LEFT JOIN edges e_cause ON sym.id = e_cause.dst_entity_id AND e_cause.edge_type = 'causes'
    LEFT JOIN entities cause ON e_cause.src_entity_id = cause.id
    LEFT JOIN edges e_sol ON sym.id = e_sol.src_entity_id AND e_sol.edge_type = 'solved_by'
    LEFT JOIN entities sol ON e_sol.dst_entity_id = sol.id
    WHERE sym.entity_type = 'Symptom'
      AND sym.name ILIKE '%timeout%'
)
SELECT * FROM symptom_analysis;

-- 類似障害の検索（同じ原因を持つ）
SELECT
    i1.name as current_incident,
    i2.name as similar_incident,
    cause.name as shared_cause
FROM entities i1
JOIN edges e1 ON i1.id = e1.src_entity_id AND e1.edge_type = 'caused_by'
JOIN entities cause ON e1.dst_entity_id = cause.id
JOIN edges e2 ON cause.id = e2.dst_entity_id AND e2.edge_type = 'caused_by'
JOIN entities i2 ON e2.src_entity_id = i2.id
WHERE i1.name = '現在の障害名'
  AND i1.id != i2.id;
```

## 5. Legal/Regulatory（法務・規約）

契約書、利用規約、コンプライアンス文書など。

### Entity Types

| Type | Description | Examples |
|------|-------------|----------|
| Clause | 条項 | 第X条、セクションY |
| Definition | 定義 | 「本サービス」の定義 |
| Requirement | 要件・義務 | 遵守事項、禁止事項 |
| Exception | 例外 | 除外条件 |
| Penalty | 罰則 | 違約金、解除条件 |
| Party | 当事者 | 甲、乙、利用者 |

### Edge Types

```
Structure:
├── contains         # 包含（親子条項）
├── refers_to        # 参照
└── amends           # 修正

Logic:
├── requires         # 必要条件
├── prohibits        # 禁止
├── permits          # 許可
├── exception_of     # 例外
└── overrides        # 上書き

Consequence:
├── triggers         # 発動条件
└── results_in       # 結果
```

### Query Examples

```sql
-- 条項の階層構造
WITH RECURSIVE clause_tree AS (
    SELECT id, name, NULL::uuid as parent_id, 0 as depth
    FROM entities
    WHERE entity_type = 'Clause' AND name = '第1条'

    UNION ALL

    SELECT e.id, e.name, ed.src_entity_id, ct.depth + 1
    FROM clause_tree ct
    JOIN edges ed ON ct.id = ed.src_entity_id AND ed.edge_type = 'contains'
    JOIN entities e ON ed.dst_entity_id = e.id
)
SELECT * FROM clause_tree ORDER BY depth, name;

-- 例外条件の検索
SELECT
    req.name as requirement,
    exc.name as exception,
    exc.description as exception_detail
FROM entities req
JOIN edges ed ON req.id = ed.src_entity_id AND ed.edge_type = 'exception_of'
JOIN entities exc ON ed.dst_entity_id = exc.id
WHERE req.entity_type = 'Requirement';
```

## Common Patterns

### Multi-type Query

```sql
-- 複数のEntity型をまたいだ検索
SELECT
    e.name,
    e.entity_type,
    e.description
FROM entities e
WHERE e.entity_type IN ('Character', 'Organization', 'Location')
  AND (e.name ILIKE '%keyword%' OR e.description ILIKE '%keyword%');
```

### Cross-reference

```sql
-- 異なるドキュメント間の関連
SELECT
    d1.title as from_doc,
    e1.name as entity,
    d2.title as to_doc
FROM mentions m1
JOIN chunks c1 ON m1.chunk_id = c1.id
JOIN documents d1 ON c1.document_id = d1.id
JOIN entities e1 ON m1.entity_id = e1.id
JOIN mentions m2 ON e1.id = m2.entity_id
JOIN chunks c2 ON m2.chunk_id = c2.id
JOIN documents d2 ON c2.document_id = d2.id
WHERE d1.id != d2.id;
```
