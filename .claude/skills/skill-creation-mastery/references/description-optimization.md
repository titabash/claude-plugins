# Description最適化

Skillのdescriptionは、Claudeがスキルを発見・起動するかどうかを決定する最も重要なフィールド。

## 仕組み

1. セッション開始時、Claudeは全インストール済みスキルの`name`と`description`をシステムプロンプトに読み込む
2. ユーザーのリクエストを受け取ると、descriptionとの意味的マッチングで起動するスキルを判断
3. マッチしたスキルのSKILL.md本文が読み込まれる

→ descriptionが曖昧だと、スキルは永遠に発見されない。

## WHAT + WHEN フォーミュラ

```
description: [WHAT: 何をするか（具体的な機能列挙）]。[WHEN: いつ使うか（トリガー条件）]
```

### 構成要素

| 要素 | 役割 | 例 |
|------|------|-----|
| WHAT | スキルの機能を具体的に列挙 | 「PDFからテキスト抽出、フォーム入力、文書マージ」 |
| WHEN | 起動すべき状況やキーワード | 「PDFファイルの操作について言及された時」 |

### 良い例

```yaml
# GraphRAG
description: PostgreSQL + pgvector + PGroonga で GraphRAG を構築。自然言語でプロジェクトを説明すると、最適なEntity/Edge型、スキーマ、クエリパターンを設計・生成。Use when the user mentions "GraphRAG", "knowledge graph", or wants to build RAG with relationships.

# UI Design Guideline
description: Create project-specific UI design guideline as a Claude Code Skill. Use when the user says "UI design guideline", "design system", "style guide", or wants to create design guidelines for their project.

# Code Reviewer
description: Review code for security, performance, and best practices. Use when user asks for code review, security audit, or performance analysis.
```

### 悪い例

```yaml
# 曖昧すぎる
description: ドキュメントを処理する

# WHENがない
description: コードレビューを行う

# 長すぎて焦点がぼやける
description: あらゆるプログラミング言語のコードを分析し、バグ、パフォーマンス問題、セキュリティ脆弱性、コードスタイル違反、テストカバレッジ不足、ドキュメント不足、アクセシビリティ問題、国際化対応...（以下省略）
```

## トリガーキーワード戦略

### バイリンガルキーワード

日本語環境では、日英両方のキーワードを含めることでトリガー率が向上:

```yaml
description: ... Use when the user mentions "GraphRAG", "knowledge graph" ...
```

日本語の説明文に加え、英語のトリガー文を末尾に追加する。

### キーワード選定の考え方

1. **ユーザーが実際に使う言葉**: 技術用語そのまま（「GraphRAG」「design system」）
2. **関連する動詞**: 「作りたい」「構築」「生成」「分析」
3. **類義語**: 「style guide」= 「design guideline」= 「デザインシステム」
4. **ユースケース**: 「知識グラフ」「関係性のあるRAG」

### 文字数制限

- **最大1024文字**（frontmatter仕様）
- 実用的には **200-400文字** が最適
- 短すぎるとマッチしにくく、長すぎると焦点がぼやける

## 評価ループ（Description Optimization Loop）

descriptionの品質を客観的に測定・改善するプロセス:

### Step 1: テストプロンプト集の作成

スキルがトリガーされるべきプロンプトを10-20個用意:

```
# トリガーされるべき（Positive）
- 「GraphRAGを構築したい」
- 「知識グラフをPostgreSQLで作りたい」
- 「RAGに関係性を持たせたい」

# トリガーされるべきでない（Negative）
- 「PostgreSQLのインデックスを最適化したい」
- 「一般的なRAGパイプラインを作りたい」
```

### Step 2: 分割とベースライン測定

- テストセットを60%トレーニング / 40%テストに分割
- 現在のdescriptionで各プロンプトを3回ずつテスト
- ベースラインのトリガー率を記録

### Step 3: 反復改善

1. 失敗したケースを分析
2. descriptionの改善版を提案
3. トレーニングセットで評価
4. テストセットで検証（過学習防止）
5. 最大5回反復
6. テストスコアが最高のdescriptionを採用

### Step 4: 回帰テスト

スキルの内容を変更するたびに、テストプロンプト集で再テスト。

## descriptionテンプレート

```yaml
# 基本パターン
description: "[動詞]で[対象]を[結果]。[具体的機能1]、[機能2]、[機能3]を含む。Use when [英語トリガー条件]。"

# ジェネレーター系
description: "[対象]を自動生成するスキル。[入力]から[出力]を作成。Use when user wants to create/generate [target]."

# 分析・レビュー系
description: "[対象]を[観点1]、[観点2]、[観点3]で分析。Use when user asks for [analysis type] or mentions [keywords]."

# ガイド・リファレンス系
description: "[分野]の高度なテクニックを指導。[トピック1]、[トピック2]を網羅。Use when user asks about [topic], [topic], or [topic]."
```

## 実践チェックリスト

- [ ] WHATが含まれているか（具体的な機能列挙）
- [ ] WHENが含まれているか（トリガー条件）
- [ ] 1024文字以内か
- [ ] 具体的なキーワードが含まれているか（曖昧な表現がないか）
- [ ] 日英バイリンガルキーワードがあるか
- [ ] Negativeケース（トリガーされるべきでない）と区別できるか
- [ ] 類義語がカバーされているか
