---
description: Generate GraphRAG schema optimized for your specific use case. Describe your project in natural language and Claude will design the optimal Entity/Edge types, queries, and schema.
argument-hint: "<プロジェクトの説明を自然言語で>"
---

# GraphRAG PostgreSQL Generator

**自然言語でプロジェクトを説明すると、最適なGraphRAGスキーマを設計・生成します。**

## Arguments

`$ARGUMENTS`: プロジェクトの説明（自然言語）

### 例

```
/graphrag 小説のキャラクター関係を管理したい。時系列で関係が変化する
/graphrag マイクロサービス間の依存関係を可視化して影響分析したい
/graphrag 社内FAQと議事録を横断検索できるナレッジベースを作りたい
/graphrag 障害報告から原因と解決策を検索できるようにしたい
/graphrag 法務文書の条項間の参照関係を追跡したい
```

## Execution Flow

### Step 1: Analyze User Requirements

**ユーザーの説明 `$ARGUMENTS` を分析**:

1. 何を管理したいか（データの種類）
2. どんな関係を追跡したいか
3. どんな検索・分析をしたいか
4. 特別な要件（時系列、ネタバレ制御、承認フロー等）

### Step 2: Read Reference Documents

以下のリファレンスを参照して、要件に最適な設計を決定:

1. **[references/use-cases.md](skills/graphrag/references/use-cases.md)** - 既存のユースケースパターンを参考に
2. **[references/architecture.md](skills/graphrag/references/architecture.md)** - アーキテクチャの基本
3. **[references/schema-design.md](skills/graphrag/references/schema-design.md)** - スキーマ設計のベストプラクティス
4. **[references/entity-extraction.md](skills/graphrag/references/entity-extraction.md)** - Entity/Edge抽出パターン

### Step 3: Design Entity/Edge Types

**ユーザーの要件に基づいて、カスタムのEntity型とEdge型を設計**:

例: 「小説のキャラクター関係を管理したい。時系列で関係が変化する」

→ 設計:
- Entity型: `Character`, `Location`, `Organization`, `Event`, `Item`
- Edge型: `friend_of`, `enemy_of`, `ally_of`, `family_of`, `located_in`, `participates_in`
- 追加機能: 時系列サポート（`events`テーブル、`valid_from/to`）

### Step 4: Confirm Design with User

AskUserQuestionで設計を確認:

1. **プロジェクト名**
2. **設計したEntity型の確認**: 「以下のEntity型でよいですか？追加/削除があれば教えてください」
3. **設計したEdge型の確認**: 「以下のEdge型でよいですか？」
4. **追加オプション**:
   - Embedding dimension: 1536 / 768 / Custom
   - Primary language: Japanese / English
   - 時系列サポート: Yes / No
   - Global Search (Community): Yes / No

### Step 5: Generate Schema

1. Read `skills/graphrag/templates/schema-core.sql`
2. **ユーザー要件に基づいてカスタマイズ**:
   - Entity型をコメント/ドキュメントとして追加
   - Edge型をコメント/ドキュメントとして追加
   - 必要な拡張テーブルを追加
3. Write to `sql/schema.sql`

### Step 6: Generate Indexes

1. Read `skills/graphrag/templates/indexes.sql`
2. 言語に応じてPGroongaを設定
3. Write to `sql/indexes.sql`

### Step 7: Generate Custom Queries

**ユーザーの検索・分析要件に基づいてクエリを生成**:

参照: [references/query-patterns.md](skills/graphrag/references/query-patterns.md)

- `sql/queries/local_search.sql` - Entity中心の検索
- `sql/queries/global_search.sql` - 全体俯瞰検索
- `sql/queries/hybrid_search.sql` - Hybrid Search
- `sql/queries/custom_*.sql` - 要件固有のクエリ（例: 依存ツリー、因果パス）

### Step 8: Generate Entity Extraction Prompts

**設計したEntity/Edge型に基づいて抽出プロンプトを生成**:

参照: [references/entity-extraction.md](skills/graphrag/references/entity-extraction.md)

- `docs/prompts/entity_extraction.md`
- `docs/prompts/edge_extraction.md`

### Step 9: Generate Documentation

参照: [references/chunking-strategies.md](skills/graphrag/references/chunking-strategies.md)

- `docs/graphrag-guide.md` - 運用ガイド（Entity/Edge型、Chunking戦略、クエリ例）

### Step 10: Report Completion

生成完了を報告:
1. 設計したEntity/Edge型のサマリー
2. 生成されたファイル一覧
3. 次のステップ（拡張セットアップ、データ投入）

## Reference Files

- [references/architecture.md](skills/graphrag/references/architecture.md) - アーキテクチャ
- [references/schema-design.md](skills/graphrag/references/schema-design.md) - スキーマ設計
- [references/use-cases.md](skills/graphrag/references/use-cases.md) - ユースケース例
- [references/entity-extraction.md](skills/graphrag/references/entity-extraction.md) - Entity/Edge抽出
- [references/query-patterns.md](skills/graphrag/references/query-patterns.md) - クエリパターン
- [references/chunking-strategies.md](skills/graphrag/references/chunking-strategies.md) - Chunking戦略
