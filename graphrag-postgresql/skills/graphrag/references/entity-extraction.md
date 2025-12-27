# Entity Extraction Guide

## Overview

LLMを使用したEntity/Edge抽出のベストプラクティス。

## Extraction Pipeline

```
Chunk Text
    │
    ▼
┌─────────────────┐
│  Entity Extract │  LLMでEntity候補を抽出
└─────────────────┘
    │
    ▼
┌─────────────────┐
│  Entity Resolve │  既存Entityとマッチング/マージ
└─────────────────┘
    │
    ▼
┌─────────────────┐
│  Edge Extract   │  Entity間の関係を抽出
└─────────────────┘
    │
    ▼
┌─────────────────┐
│  Validation     │  信頼度でフィルタ
└─────────────────┘
```

## Entity Extraction

### Prompt Template

```markdown
# Entity Extraction Task

以下のテキストから、重要な「エンティティ」を抽出してください。

## エンティティタイプ
- Person: 人物、キャラクター
- Organization: 組織、会社、団体
- Location: 場所、地名、国
- Product: 製品、サービス
- Technology: 技術、ツール、フレームワーク
- Concept: 概念、用語、理論
- Event: 出来事、イベント

## 出力形式
JSON配列で出力してください:

```json
[
  {
    "name": "正規名（最も一般的な表記）",
    "type": "エンティティタイプ",
    "aliases": ["別名1", "別名2"],
    "description": "簡潔な説明（1-2文）",
    "confidence": 0.0-1.0
  }
]
```

## 注意事項
- 重複を避け、同一エンティティはマージ
- 曖昧な参照（「彼」「それ」）は除外
- 固有名詞を優先
- confidenceは確信度に基づいて設定

---

## テキスト

{chunk_text}
```

### Entity Types by Use Case

#### Story/Content（物語）
```
Person: キャラクター、著者
Organization: 組織、王国、ギルド
Location: 場所、地名、異世界の地名
Item: アイテム、武器、道具
Event: 事件、戦い、イベント
Concept: 魔法、能力、設定
```

#### Technical Docs（技術文書）
```
Technology: 言語、フレームワーク、ライブラリ
Product: サービス、ツール、API
Concept: 概念、パターン、プロトコル
Organization: 会社、プロジェクト、コミュニティ
Person: 著者、コントリビューター
```

#### Knowledge Base（ナレッジ）
```
Concept: 用語、定義、ポリシー
Process: 手順、ワークフロー
Person: 担当者、ロール
Organization: 部署、チーム
Document: 関連文書、規定
```

#### Incident（障害）
```
Symptom: 症状、エラー
Cause: 原因、根本原因
Solution: 解決策、ワークアラウンド
Component: コンポーネント、サービス
Timeline: 発生日時、期間
```

## Edge Extraction

### Prompt Template

```markdown
# Relation Extraction Task

以下のテキストとエンティティリストから、エンティティ間の「関係」を抽出してください。

## エンティティリスト
{entities_json}

## 関係タイプ
- works_at: 所属（Person → Organization）
- friend_of: 友人関係（Person ↔ Person）
- enemy_of: 敵対関係（Person ↔ Person）
- depends_on: 依存（Technology → Technology）
- part_of: 構成（Component → System）
- located_in: 場所（Entity → Location）
- causes: 原因（Cause → Effect）
- solved_by: 解決（Problem → Solution）

## 出力形式
JSON配列で出力してください:

```json
[
  {
    "src_entity": "ソースエンティティ名",
    "dst_entity": "ターゲットエンティティ名",
    "edge_type": "関係タイプ",
    "description": "関係の説明",
    "weight": 1.0,
    "confidence": 0.0-1.0
  }
]
```

## 注意事項
- 方向性のある関係は正しい向きで
- 推測ではなく、テキストに根拠がある関係のみ
- 同じ関係の重複を避ける
- confidenceはテキスト中の明確さに基づいて設定

---

## テキスト

{chunk_text}
```

### Edge Types by Use Case

#### Story/Content
```
friend_of, enemy_of: 人間関係
ally_of, betrayed: 同盟・裏切り
related_to: 親族関係
mentor_of: 師弟関係
loves, hates: 感情関係
possesses: 所有（Item）
located_in: 場所関係
participates_in: イベント参加
```

#### Technical Docs
```
depends_on: 依存関係
extends: 継承・拡張
implements: 実装
uses: 使用
alternative_to: 代替
compatible_with: 互換性
requires: 必要条件
```

#### Knowledge Base
```
defines: 定義
refers_to: 参照
supersedes: 置き換え
approves: 承認関係
responsible_for: 責任
follows: 手順の順序
```

#### Incident
```
causes: 原因
caused_by: 被原因
solved_by: 解決策
workaround_for: 回避策
affects: 影響
related_to: 関連
occurred_at: 発生場所/時間
```

## Entity Resolution

### Same Entity Detection

```python
def is_same_entity(entity1, entity2):
    """
    同一エンティティかどうかを判定
    """
    # 1. 名前の完全一致
    if entity1.name.lower() == entity2.name.lower():
        return True

    # 2. 別名の一致
    if entity1.name.lower() in [a.lower() for a in entity2.aliases]:
        return True
    if entity2.name.lower() in [a.lower() for a in entity1.aliases]:
        return True

    # 3. Embedding類似度（閾値: 0.95）
    if cosine_similarity(entity1.embedding, entity2.embedding) > 0.95:
        return True

    return False
```

### Merge Strategy

```python
def merge_entities(existing, new):
    """
    既存エンティティに新規情報をマージ
    """
    # 別名を追加
    existing.aliases = list(set(existing.aliases + new.aliases + [new.name]))

    # descriptionは長い方を採用
    if len(new.description or '') > len(existing.description or ''):
        existing.description = new.description

    # confidenceは平均
    existing.confidence = (existing.confidence + new.confidence) / 2

    return existing
```

## Confidence Handling

### Confidence Levels

| Level | Range | Meaning |
|-------|-------|---------|
| High | 0.9-1.0 | 明確に記述されている |
| Medium | 0.7-0.9 | 文脈から推測可能 |
| Low | 0.5-0.7 | やや曖昧 |
| Very Low | <0.5 | 推測の域を出ない |

### Filtering Strategy

```sql
-- 高信頼度のみ（本番検索）
SELECT * FROM edges WHERE confidence >= 0.8;

-- 中信頼度以上（探索的検索）
SELECT * FROM edges WHERE confidence >= 0.6;

-- 段階的拡張
WITH results AS (
    SELECT * FROM edges WHERE confidence >= 0.9
)
SELECT * FROM results
UNION ALL
SELECT * FROM edges
WHERE confidence >= 0.7
  AND (SELECT COUNT(*) FROM results) < 10;
```

## Batch Processing

### Recommended Flow

```python
async def process_document(document_id):
    # 1. Chunkを取得
    chunks = get_chunks(document_id)

    # 2. 並列でEntity抽出
    entity_tasks = [extract_entities(chunk) for chunk in chunks]
    all_entities = await asyncio.gather(*entity_tasks)

    # 3. Entity Resolution
    resolved_entities = resolve_entities(flatten(all_entities))

    # 4. DBに保存
    save_entities(resolved_entities)

    # 5. Edge抽出（Entity確定後）
    edge_tasks = [extract_edges(chunk, resolved_entities) for chunk in chunks]
    all_edges = await asyncio.gather(*edge_tasks)

    # 6. Edge重複排除・保存
    save_edges(dedupe_edges(flatten(all_edges)))
```

### Batch Size

| Model | Recommended Batch |
|-------|-------------------|
| GPT-4 | 5-10 chunks |
| GPT-3.5 | 10-20 chunks |
| Claude | 5-10 chunks |

## Quality Assurance

### Validation Rules

```python
def validate_entity(entity):
    errors = []

    # 名前が空でないこと
    if not entity.name or len(entity.name) < 2:
        errors.append("name too short")

    # typeが有効な値であること
    if entity.type not in VALID_ENTITY_TYPES:
        errors.append(f"invalid type: {entity.type}")

    # confidenceが範囲内であること
    if not 0 <= entity.confidence <= 1:
        errors.append("confidence out of range")

    return errors

def validate_edge(edge):
    errors = []

    # src/dstが存在すること
    if not entity_exists(edge.src_entity):
        errors.append(f"src_entity not found: {edge.src_entity}")
    if not entity_exists(edge.dst_entity):
        errors.append(f"dst_entity not found: {edge.dst_entity}")

    # 自己参照でないこと
    if edge.src_entity == edge.dst_entity:
        errors.append("self-reference not allowed")

    return errors
```

### Human Review Queue

```sql
-- 低信頼度のエンティティをレビューキューに
CREATE VIEW entity_review_queue AS
SELECT * FROM entities
WHERE confidence < 0.7
ORDER BY created_at DESC;

-- 矛盾する関係をレビューキューに
CREATE VIEW edge_conflict_queue AS
SELECT e1.*, e2.*
FROM edges e1
JOIN edges e2 ON e1.src_entity_id = e2.src_entity_id
             AND e1.dst_entity_id = e2.dst_entity_id
WHERE e1.edge_type != e2.edge_type
  AND e1.id < e2.id;
```
