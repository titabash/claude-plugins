# マルチフェーズ実行フローパターン

スキルの実行を段階的なフェーズに分割する設計パターン。

## 標準パターン（6フェーズ）

ほとんどのスキルは以下の基本フローに沿う:

```
Phase 1: 要件分析 (Analyze)
    ↓
Phase 2: リファレンス読み込み (Read)
    ↓
Phase 3: 設計 (Design)
    ↓
Phase 4: ユーザー確認 (Confirm)
    ↓
Phase 5: 生成/実行 (Generate)
    ↓
Phase 6: 完了レポート (Report)
```

### Phase 1: 要件分析 (Analyze)

**目的**: ユーザーの入力を解析し、実行パラメータを決定

**パターン**:
- `$ARGUMENTS`の自然言語解析
- AskUserQuestionによる構造化質問
- 既存ファイルの存在チェック

```markdown
### Phase 1: ユーザー要件の分析
$ARGUMENTSまたはAskUserQuestionで以下を確認:
1. プロジェクト名（必須）
2. 対象プラットフォーム（選択式）
3. オプション設定
```

### Phase 2: リファレンス読み込み (Read)

**目的**: 設計に必要な知識をコンテキストに読み込む

**重要**: 必要なファイルのみを読み込む（全リファレンスを読まない）

```markdown
### Phase 2: リファレンス読み込み
Read [references/architecture.md](references/architecture.md)
Read [references/schema-design.md](references/schema-design.md)

**時系列サポートが必要な場合のみ**:
Read [references/time-series.md](references/time-series.md)
```

### Phase 3: 設計 (Design)

**目的**: 読み込んだ知識とユーザー要件を組み合わせて設計

```markdown
### Phase 3: Entity/Edge型の設計
references/use-cases.mdの類似パターンを参考に、
ユーザー要件に最適なカスタム設計を行う。
```

### Phase 4: ユーザー確認 (Confirm)

**目的**: 生成前に設計内容の承認を得る

```markdown
### Phase 4: 設計確認
AskUserQuestionで以下を確認:
1. 「以下のEntity型を提案します。追加/削除があれば教えてください」
2. 「以下のオプションでよろしいですか？」
```

### Phase 5: 生成/実行 (Generate)

**目的**: 確認済みの設計に基づいてファイル生成やコード実行

```markdown
### Phase 5: ファイル生成
1. Read templates/schema-core.sql
2. 設計内容でカスタマイズ
3. Write to sql/schema.sql
```

### Phase 6: 完了レポート (Report)

**目的**: 何が生成されたか、次に何をすべきかを報告

```markdown
### Phase 6: 完了レポート
1. 生成したファイル一覧
2. 各ファイルの概要
3. 次のステップ
```

## 実例分析

### GraphRAG PostgreSQL（10フェーズ）

標準6フェーズを細分化した高度な例:

| Phase | 内容 | 標準パターンとの対応 |
|-------|------|---------------------|
| 1 | ユーザー要件分析 | Analyze |
| 2 | リファレンス読み込み | Read |
| 3 | Entity/Edge型設計 | Design |
| 4 | ユーザー確認 | Confirm |
| 5 | スキーマ生成 | Generate (1/5) |
| 6 | インデックス生成 | Generate (2/5) |
| 7 | クエリ生成 | Generate (3/5) |
| 8 | 抽出プロンプト生成 | Generate (4/5) |
| 9 | ドキュメント生成 | Generate (5/5) |
| 10 | 完了レポート | Report |

**設計判断**: Generateフェーズが5つに分割されている。これは各生成物が独立しており、異なるリファレンスとテンプレートを使用するため。

### UI Design Guideline（5フェーズ）

シンプルだが効果的な例:

| Phase | 内容 | 標準パターンとの対応 |
|-------|------|---------------------|
| 1 | 既存スキルチェック | Analyze（前提条件確認） |
| 2 | 情報収集 | Analyze + Confirm |
| 3 | ディレクトリ作成 | Generate（準備） |
| 4 | ファイル生成 | Generate |
| 5 | 完了レポート | Report |

**設計判断**: AnalyzeとConfirmが統合（Phase 2）。質問と確認が一連の流れで完結するため。

## フェーズ数の判断基準

| フェーズ数 | 適切なケース |
|-----------|-------------|
| 3-4 | シンプルなスキル（分析→生成→報告） |
| 5-6 | 標準的なスキル（標準パターン） |
| 7-10 | 複雑なスキル（複数の生成物、多段階確認） |
| 10+ | 分割を検討。複数スキルに分けるか、サブフェーズを使う |

## フェーズ設計のガイドライン

### 1. 各フェーズは単一責任

```markdown
# 良い例
### Phase 5: スキーマ生成
### Phase 6: インデックス生成

# 悪い例
### Phase 5: スキーマとインデックスの生成
```

### 2. 早期にユーザー確認を入れる

生成量が多い場合、全生成後ではなく設計段階で確認を入れる。
→ 手戻りのコストを最小化。

### 3. 条件分岐は明示的に

```markdown
### Phase 3: 追加機能の設計

**時系列サポートが必要な場合**:
Read references/time-series.md → events テーブルを追加

**Global Searchが必要な場合**:
Read references/community-detection.md → community テーブルを追加

**どちらも不要な場合**:
Phase 4へ進む
```

### 4. リファレンス読み込みは使用直前に

```markdown
# 良い例: 使用直前に読み込み
### Phase 5: スキーマ生成
Read templates/schema-core.sql
カスタマイズしてWrite

### Phase 6: インデックス生成
Read references/indexing-strategies.md
Read templates/indexes.sql
カスタマイズしてWrite

# 悪い例: 最初に全部読み込み
### Phase 2: 全リファレンス読み込み
Read references/architecture.md
Read references/schema-design.md
Read references/indexing-strategies.md
Read references/query-patterns.md
（← コンテキストを無駄に消費）
```

## フェーズ記述テンプレート

```markdown
### Phase N: [フェーズ名]

**目的**: [このフェーズで達成すること]

**入力**: [前フェーズからの入力]

**手順**:
1. [ステップ1]
2. [ステップ2]
3. [ステップ3]

**出力**: [次フェーズへの出力またはファイル生成]

**条件分岐**:
- [条件A]の場合: [対応]
- [条件B]の場合: [対応]
```
