# User Interactionパターン

AskUserQuestionツールを使ったユーザー対話の設計パターン。

## 基本原則

1. **構造化質問を優先**: 自由入力より選択肢付き質問
2. **必須→任意の順**: 重要な質問を先に
3. **確認は生成前に**: 手戻りコストが高い操作の前に確認
4. **1回の質問で複数情報**: 質問回数を最小化

## 質問タイプ

### 1. 選択式質問

最も推奨される形式。ユーザーの負担が少なく、スキルの処理も確実。

```markdown
AskUserQuestionで以下を確認:
「対象プラットフォームを選択してください」
- Web
- iOS
- Android
- React Native
- Flutter
```

### 2. 選択+自由入力ハイブリッド

選択肢で基本を押さえつつ、カスタマイズの余地を残す。

```markdown
AskUserQuestionで以下を確認:
「Embedding dimensionを選択してください」
- 1536 (OpenAI ada-002)
- 768 (多くのOSSモデル)
- Custom (数値を指定)
```

### 3. 確認式質問（Yes/No）

既存状態の確認や、設計の承認に使用。

```markdown
AskUserQuestionで確認:
「デザインガイドラインスキルが既に存在します。上書きしますか？」
- Overwrite
- Cancel
```

### 4. 構造化情報収集

複数の情報を1回の質問でまとめて収集。

```markdown
AskUserQuestionで以下を確認:
「以下の情報を教えてください:
1. プロジェクト名（必須）
2. プライマリブランドカラー（例: #3B82F6）
3. アクセシビリティレベル: WCAG 2.1 AA / AAA
4. 参考URL（任意）」
```

## 質問設計のパターン

### パターン1: 段階的質問（推奨）

Phase分割と連携し、段階的に質問する。

```markdown
### Phase 1: 基本情報
AskUserQuestion:
1. プロジェクト名
2. 対象プラットフォーム

### Phase 3: 設計確認
AskUserQuestion:
「以下のEntity型を提案します:
- Character, Location, Organization, Event, Item
追加/削除/変更があれば教えてください」

### Phase 4: オプション
AskUserQuestion:
- Embedding dimension: 1536 / 768 / Custom
- Primary language: Japanese / English
- 時系列サポート: Yes / No
```

**利点**: 前のフェーズの結果に基づいて次の質問を調整できる。

### パターン2: 一括質問

シンプルなスキルで質問が少ない場合。

```markdown
### Phase 1: 情報収集
AskUserQuestionで以下を一括確認:
1. プロジェクト名（必須）
2. プライマリカラー（例: #3B82F6）
3. フォントファミリー（デフォルト: system-ui）
4. アクセシビリティレベル: AA / AAA
```

**注意**: 5項目以上の場合は段階的質問を推奨。

### パターン3: 条件分岐付き質問

前の回答によって次の質問が変わる。

```markdown
### Phase 1: プロジェクト種別
AskUserQuestion:
「プロジェクトの種類を選択してください」
- Webアプリケーション
- モバイルアプリ
- デスクトップアプリ

### Phase 2: 詳細設定
**Webの場合**:
AskUserQuestion: 「フレームワーク: React / Vue / Svelte / Other」

**モバイルの場合**:
AskUserQuestion: 「プラットフォーム: iOS / Android / クロスプラットフォーム」
```

## 提案→確認パターン

ユーザーにゼロから情報を求めるのではなく、スキルが提案して確認を求める。

### 悪い例

```markdown
AskUserQuestion:
「どのようなEntity型が必要ですか？」
（← ユーザーはEntity型の選択肢を知らないかもしれない）
```

### 良い例

```markdown
AskUserQuestion:
「プロジェクト分析の結果、以下のEntity型を提案します:

| Entity型 | 説明 |
|----------|------|
| Character | 登場人物 |
| Location | 場所 |
| Organization | 組織 |
| Event | イベント |
| Item | アイテム |

追加/削除/変更があれば教えてください。
そのままでよければ「OK」と回答してください。」
```

## 既存状態チェック + 確認

ファイル上書きなどの破壊的操作前に確認。

```markdown
### Phase 1: 既存チェック
ls -la .claude/skills/design-guideline/

**存在する場合**:
AskUserQuestion:
「デザインガイドラインスキルが既に存在します。」
- 上書き（既存の内容は失われます）
- キャンセル

**Cancel選択時**: 実行を停止
```

## エラー回復

ユーザーの入力が不正な場合の対処。

```markdown
### 入力バリデーション
プロジェクト名が空の場合:
AskUserQuestion:
「プロジェクト名は必須です。プロジェクト名を入力してください。」
```

## チェックリスト

- [ ] 自由入力ではなく選択肢を提示しているか
- [ ] 必須項目と任意項目が区別されているか
- [ ] デフォルト値が提示されているか
- [ ] 破壊的操作の前に確認があるか
- [ ] 提案→確認パターンを使っているか（ゼロからの自由入力を避ける）
- [ ] 質問回数が最小化されているか（5項目以上は段階的に）
