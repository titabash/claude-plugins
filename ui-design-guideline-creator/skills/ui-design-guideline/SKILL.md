---
name: ui-design-guideline
description: Create project-specific UI design guideline as a Claude Code Skill. Use when the user says "UIデザインガイドライン", "デザインシステム", "スタイルガイド", "design system", "style guide", or wants to create design guidelines for their project.
---

# UIデザインガイドラインスキル生成

このスキルは、ユーザーと対話しながらプロジェクト固有のUIデザインガイドラインを **Claude Codeスキル** として `.claude/skills/design-guideline/` に生成・登録します。

## 出力先（重要）

生成されたスキルは以下の構造で配置されます：

```
.claude/
└── skills/
    └── design-guideline/
        ├── SKILL.md              # メイン（500行以下）
        └── references/
            ├── colors.md         # カラーシステム
            ├── typography.md     # タイポグラフィ
            ├── spacing.md        # スペーシング
            ├── components.md     # コンポーネント
            └── tokens.json       # デザイントークン
```

## 実行フロー

### Phase 1: 情報収集

AskUserQuestionツールで以下を質問：

1. **プロジェクト名**（必須）
2. **対象プラットフォーム**: Web / iOS / Android / React Native / Flutter
3. **プライマリブランドカラー**（例: #3B82F6）
4. **アクセシビリティレベル**: WCAG 2.1 AA / AAA
5. **参考URL**（オプション）- 指定時はWebFetchで解析

### Phase 2: ディレクトリ作成

```bash
mkdir -p .claude/skills/design-guideline/references
```

### Phase 3: ファイル生成

以下のファイルを順番に生成：

#### 3.1 SKILL.md（メインファイル）

`templates/skill-template.md` を参照して生成。

**重要**: 500行以下に収める。詳細は references/ へのリンクで参照。

```yaml
---
name: design-guideline
description: {PROJECT_NAME}のUIデザインガイドライン。Use when developing UI components, styling, or making design decisions.
---
```

#### 3.2 references/colors.md

`references/color-systems.md` を参照して生成。

- プライマリカラーパレット（50-900スケール）
- セカンダリカラーパレット
- グレースケール
- セマンティックカラー

#### 3.3 references/typography.md

`references/typography-scales.md` を参照して生成。

- フォントファミリー
- サイズスケール（xs-6xl）
- 見出しスタイル

#### 3.4 references/spacing.md

`references/spacing-systems.md` を参照して生成。

- 8pxベーススペーシング
- グリッド・ブレークポイント

#### 3.5 references/components.md

`references/component-patterns.md` を参照して生成。

20+ コンポーネント仕様（Button, Input, Card, Modal等）

#### 3.6 references/tokens.json

`templates/design-tokens.json` を参照して生成。

### Phase 4: 完了報告

生成完了後、ユーザーに以下を報告：

1. 生成されたファイル一覧
2. スキルの使用方法（Claudeが自動的に参照）
3. カスタマイズ方法

## 参照ファイル

生成時に必ず参照：

- [references/color-systems.md](references/color-systems.md) - カラーシステムのベストプラクティス
- [references/typography-scales.md](references/typography-scales.md) - タイポグラフィ
- [references/spacing-systems.md](references/spacing-systems.md) - スペーシング
- [references/component-patterns.md](references/component-patterns.md) - コンポーネント
- [references/accessibility.md](references/accessibility.md) - アクセシビリティ

## テンプレートファイル

- [templates/skill-template.md](templates/skill-template.md) - SKILL.mdのテンプレート
- [templates/design-tokens.json](templates/design-tokens.json) - トークンのテンプレート
