# GraphRAG PostgreSQL Plugin

PostgreSQL + pgvector + PGroonga で構築する汎用 GraphRAG スキルプラグイン。

## 概要

このプラグインは、PostgreSQL単体でGraphRAG（Graph-enhanced Retrieval-Augmented Generation）を実現するためのスキーマ設計、インデックス戦略、クエリパターンを提供します。

### 特徴

- **3レイヤーアーキテクチャ**: Evidence（根拠）→ Entity（概念）→ Community（コミュニティ）
- **Hybrid Search**: PGroonga（レキシカル）+ pgvector（セマンティック）+ Graph（関係）
- **汎用設計**: 物語から技術文書、ナレッジベースまで幅広く対応
- **日本語対応**: PGroonga + TokenMecab による高品質な日本語検索

## 対応ユースケース

| ユースケース | Entity例 | Edge例 |
|-------------|----------|--------|
| **物語・コンテンツ** | Character, Location, Item | friend_of, enemy_of, possesses |
| **技術文書** | Technology, API, Component | depends_on, implements, extends |
| **ナレッジベース** | Concept, Process, Role | defines, precedes, references |
| **障害・トラブル** | Symptom, Cause, Solution | causes, solved_by, affects |

## インストール

### 前提条件

- PostgreSQL 14+
- pgvector 0.5.0+
- PGroonga 3.0+

### 拡張機能のセットアップ

```sql
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pgroonga;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

## 使い方

### スキルの呼び出し

**自然言語でプロジェクトを説明**すると、Claude が最適なGraphRAGスキーマを設計・生成します：

```bash
# 物語・コンテンツ
/graphrag 小説のキャラクター関係を管理したい。時系列で関係が変化する

# 技術文書
/graphrag マイクロサービス間の依存関係を可視化して影響分析したい

# ナレッジベース
/graphrag 社内FAQと議事録を横断検索できるナレッジベースを作りたい

# 障害・トラブル
/graphrag 障害報告から原因と解決策を検索できるようにしたい

# 法務
/graphrag 法務文書の条項間の参照関係を追跡したい
```

### フロー

1. **要件分析**: Claudeがあなたの説明を分析
2. **設計提案**: 最適なEntity型・Edge型を提案
3. **確認**: 追加・削除があれば調整
4. **生成**: スキーマ、インデックス、クエリを生成

### 生成されるファイル

```
{project}/
├── sql/
│   ├── schema.sql          # テーブル定義
│   ├── indexes.sql         # インデックス定義
│   └── queries/
│       ├── local_search.sql
│       ├── global_search.sql
│       └── hybrid_search.sql
└── docs/
    └── graphrag-guide.md   # 運用ガイド
```

## アーキテクチャ

```
┌─────────────────────────────────────────────────────────────┐
│                    Query Layer                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │ Local Search│  │Global Search│  │Hybrid Search│          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
                           │
┌─────────────────────────────────────────────────────────────┐
│                    Graph Layer                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ Entities ←──edges──→ Entities                        │    │
│  │     │                                                │    │
│  │     └──── Communities (hierarchical) ────┘          │    │
│  │              │                                       │    │
│  │         Community Reports                           │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                           │
┌─────────────────────────────────────────────────────────────┐
│                   Evidence Layer                             │
│  Documents ──→ Chunks ──→ Embeddings                        │
└─────────────────────────────────────────────────────────────┘
```

## 検索パターン

### Local Search
特定のEntityに関する詳細情報を取得。
- 「Xについて教えて」
- 「Xの使い方は？」

### Global Search
全体俯瞰、テーマ抽出、サマリー系の質問。
- 「最近の動向は？」
- 「主要なトピックは？」

### Hybrid Search
固有名詞 + 意味理解の複合検索。
- 「製品Aの不具合で〇〇に関連するもの」

## リファレンス

詳細なドキュメントは `skills/graphrag/references/` を参照:

- `architecture.md` - 全体アーキテクチャ
- `schema-design.md` - スキーマ設計ガイド
- `indexing-strategies.md` - インデックス戦略
- `entity-extraction.md` - Entity/Edge抽出パターン
- `community-detection.md` - コミュニティ検出
- `query-patterns.md` - クエリパターン詳細
- `chunking-strategies.md` - Chunking戦略
- `use-cases.md` - ユースケース別設計

## ライセンス

MIT License

## 関連リンク

- [Microsoft GraphRAG](https://microsoft.github.io/graphrag/)
- [pgvector](https://github.com/pgvector/pgvector)
- [PGroonga](https://pgroonga.github.io/)
