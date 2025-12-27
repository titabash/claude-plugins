# GraphRAG Architecture

## Overview

GraphRAGは「テキスト → 知識グラフ化 → コミュニティ階層化 → 問い合わせ時の使い分け」を実現するアーキテクチャ。

## 3 Layer Structure

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
│  │ Entities (nodes) ←──edges──→ Entities               │    │
│  │     │                            │                   │    │
│  │     └──── Communities (hierarchical) ────┘          │    │
│  │              │                                       │    │
│  │         Community Reports (summaries)               │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                           │
┌─────────────────────────────────────────────────────────────┐
│                   Evidence Layer                             │
│  ┌──────────┐     ┌──────────┐     ┌──────────────┐        │
│  │ Documents │ ──→ │  Chunks  │ ──→ │  Embeddings  │        │
│  └──────────┘     └──────────┘     └──────────────┘        │
│                        │                                     │
│                   mentions (chunk ←→ entity)                │
└─────────────────────────────────────────────────────────────┘
```

### 1. Evidence Layer（根拠層）

テキストデータを管理する基盤層。

| Component | Description |
|-----------|-------------|
| Documents | 元文書（PDF、Markdown等）のメタデータ |
| Chunks | 文書を分割したテキスト断片 |
| Chunk Embeddings | Chunkのベクトル表現（pgvector） |

### 2. Graph Layer（グラフ層）

知識グラフを構成する層。

| Component | Description |
|-----------|-------------|
| Entities | 抽出された概念（人物、場所、用語等） |
| Entity Embeddings | Entityのベクトル表現（オプション） |
| Edges | Entity間の関係（方向性、重み、時間軸） |
| Mentions | Chunk内でのEntity出現位置 |

### 3. Community Layer（コミュニティ層）

Global Searchを可能にする階層的なグルーピング。

| Component | Description |
|-----------|-------------|
| Communities | Entityのクラスタ（Leiden等で検出） |
| Community Reports | 各コミュニティの要約テキスト |

## Data Flow

### Indexing Flow（データ投入時）

```
Raw Documents
    │
    ▼
┌─────────────────┐
│  1. Chunking    │  文書をChunkに分割
└─────────────────┘
    │
    ▼
┌─────────────────┐
│  2. Embedding   │  Chunkをベクトル化
└─────────────────┘
    │
    ▼
┌─────────────────┐
│  3. Extraction  │  LLMでEntity/Edge抽出
└─────────────────┘
    │
    ▼
┌─────────────────┐
│  4. Community   │  Leidenでコミュニティ検出
│     Detection   │
└─────────────────┘
    │
    ▼
┌─────────────────┐
│  5. Summarize   │  コミュニティ要約生成
└─────────────────┘
```

### Query Flow（検索時）

#### Local Search
特定のEntityに関する詳細情報を取得。

```
Query → Entity Linking → n-hop Expansion → Evidence Retrieval → Response
```

- キーワードが明確な質問向け
- 例: 「Xについて教えて」「Xの使い方は？」

#### Global Search
全体俯瞰、テーマ抽出、サマリー系の質問。

```
Query → Community Selection → Report Aggregation → Response
```

- キーワードが薄い質問向け
- 例: 「最近の動向をまとめて」「主要なトピックは？」

#### Hybrid Search
Lexical + Semanticの統合検索。

```
Query → PGroonga (lexical) ─┐
                            ├→ RRF Fusion → Rerank → Response
Query → pgvector (semantic)─┘
```

- 固有名詞 + 意味理解が必要な質問向け
- 例: 「製品Aの不具合で〇〇に関連するもの」

## Microsoft GraphRAG Reference

Microsoft GraphRAGの中核設計:

1. **Entity/Relation/Claim抽出**: LLMでテキストから知識を抽出
2. **Leiden Community Detection**: グラフをコミュニティに分割
3. **Hierarchical Summarization**: コミュニティごとに要約を生成
4. **Query Routing**: Global/Local/DRIFTモードで使い分け

### 特徴

- **Global Search**: キーワードが薄い「Catch me up on...」系の質問に強い
- **Local Search**: 特定トピックの深掘りに最適
- **DRIFT Search**: Global→Localの段階的な探索

## PostgreSQL Implementation

PostgreSQLでGraphRAGを実現するための要素:

| 要素 | PostgreSQL実装 |
|------|----------------|
| Vector Search | pgvector (HNSW/IVFFlat) |
| Lexical Search | PGroonga (TokenMecab for Japanese) |
| Graph Traversal | Recursive CTE / WITH RECURSIVE |
| Community Detection | 外部Python (igraph/networkx) → 結果をDBに格納 |

## Best Practices

### 1. Schema Design
- `source_id`で出典を必ず追跡可能に
- `confidence`でノイズを制御
- `valid_from/valid_to`で時間軸を表現

### 2. Indexing
- 初期はHNSWを推奨（バランス良い）
- フィルタが多い場合は`iterative_scan`を検討

### 3. Query
- Local/Global/Hybridを質問タイプで使い分け
- RRFで異種ランキングを統合
- 必ずevidenceを返してハルシネーション対策

### 4. Maintenance
- Community再検出は定期バッチで
- Embedding更新は差分で
- 古いデータのarchive戦略を検討
