---
name: design-guideline
description: {{PROJECT_NAME}}のUIデザインガイドライン。カラー、タイポグラフィ、スペーシング、コンポーネント仕様を定義。Use when developing UI components, styling elements, or making design decisions for this project.
---

# {{PROJECT_NAME}} デザインガイドライン

プラットフォーム: {{PLATFORM}}
アクセシビリティ: {{ACCESSIBILITY_LEVEL}}

## クイックリファレンス

| カテゴリ | 概要 | 詳細 |
|---------|------|------|
| カラー | Primary: {{PRIMARY_COLOR}} | [colors.md](references/colors.md) |
| タイポグラフィ | {{FONT_FAMILY_SHORT}} | [typography.md](references/typography.md) |
| スペーシング | 8px ベース | [spacing.md](references/spacing.md) |
| コンポーネント | 20+ 定義済み | [components.md](references/components.md) |

## カラーシステム（概要）

- **Primary**: {{PRIMARY_COLOR}} - メインブランドカラー
- **Secondary**: {{SECONDARY_COLOR}} - サブカラー
- **Gray**: #6B7280 - テキスト・ボーダー
- **Semantic**: Success/Warning/Error/Info

詳細は [references/colors.md](references/colors.md) を参照

## タイポグラフィ（概要）

- **フォント**: {{FONT_FAMILY_SHORT}}
- **スケール**: xs(12px) sm(14px) base(16px) lg(18px) xl(20px) 2xl(24px) 3xl(30px) 4xl(36px)

詳細は [references/typography.md](references/typography.md) を参照

## スペーシング（概要）

8px ベースシステム: 0, 4, 8, 12, 16, 24, 32, 48, 64, 96px

詳細は [references/spacing.md](references/spacing.md) を参照

## コンポーネント（概要）

### 入力系
Button, Input, Textarea, Select, Checkbox, Radio, Switch

### フィードバック系
Alert, Toast, Badge, Tag, Tooltip

### レイアウト系
Card, Modal, Drawer, Tabs, Navigation

### データ表示系
Table, List, Pagination, Avatar

詳細は [references/components.md](references/components.md) を参照

## デザイントークン

[references/tokens.json](references/tokens.json) を参照

## 使用上の注意

1. **コンポーネント実装時**: 必ず上記リファレンスを参照
2. **カラー使用時**: コントラスト比を確認（WCAG {{ACCESSIBILITY_LEVEL}}準拠）
3. **スペーシング**: 8px の倍数を使用
4. **フォント**: 指定されたスケールを使用
