---
description: UIデザインガイドラインスキルを作成し .claude/skills/ に登録する
argument-hint: "[URL(optional)]"
---

# UIデザインガイドラインスキル作成

プロジェクト固有のUIデザインガイドラインを **Claude Codeスキル** として作成し、`.claude/skills/design-guideline/` に登録します。

## 引数

- URL（オプション）: $ARGUMENTS

URLが指定された場合は、そのサイトのデザインを解析してベースにしてください。

## 出力先

```
.claude/
└── skills/
    └── design-guideline/
        ├── SKILL.md              # メイン（概要、500行以下）
        └── references/
            ├── colors.md         # カラーシステム詳細
            ├── typography.md     # タイポグラフィ詳細
            ├── spacing.md        # スペーシング詳細
            ├── components.md     # コンポーネント仕様
            └── tokens.json       # デザイントークン
```

## 実行手順

1. ユーザーに以下の質問をする（AskUserQuestionツールを使用）：
   - プロジェクト名
   - 対象プラットフォーム（Web/iOS/Android/React Native/Flutter）
   - プライマリブランドカラー
   - アクセシビリティレベル（WCAG 2.1 AA/AAA）
   - その他の要望

2. `.claude/skills/design-guideline/` ディレクトリを作成

3. 収集した情報を基に、以下のファイルを生成：

### SKILL.md（メインファイル、500行以下）

```yaml
---
name: design-guideline
description: {プロジェクト名}のUIデザインガイドライン。カラー、タイポグラフィ、スペーシング、コンポーネント仕様を定義。Use when developing UI components, styling elements, or making design decisions for this project.
---
```

- クイックリファレンステーブル
- 各セクションの概要（詳細は references/ へのリンク）

### references/colors.md
- プライマリカラーパレット（50-900スケール）
- セカンダリカラーパレット
- グレースケール
- セマンティックカラー（Success/Warning/Error/Info）
- 用途別カラートークン

### references/typography.md
- フォントファミリー
- フォントサイズスケール（xs-6xl）
- 見出しスタイル（H1-H6）
- 行間・字間

### references/spacing.md
- 8pxベーススペーシングシステム
- グリッドシステム
- ブレークポイント
- コンテナ幅

### references/components.md
- Button, Input, Textarea, Select
- Checkbox, Radio, Switch
- Card, Modal, Drawer
- Alert, Toast, Badge, Tag
- Avatar, Navigation, Tabs
- Pagination, Table, List, Divider
- 各コンポーネントのバリアント、サイズ、状態

### references/tokens.json
- デザイントークン（JSON形式）

## 参照

詳細な手順は skills/ui-design-guideline/SKILL.md を参照してください。
