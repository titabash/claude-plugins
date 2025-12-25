---
description: UIデザインガイドラインを対話的に作成する
argument-hint: "[URL(optional)]"
---

# UIデザインガイドライン作成

包括的なUIデザインガイドラインを対話的に作成してください。

## 引数

- URL（オプション）: $ARGUMENTS

URLが指定された場合は、そのサイトのデザインを解析してベースにしてください。

## 実行手順

1. ユーザーに以下の質問をする（AskUserQuestionツールを使用）：
   - プロジェクト名
   - 対象プラットフォーム（Web/iOS/Android/React Native/Flutter）
   - プライマリブランドカラー
   - アクセシビリティレベル（WCAG 2.1 AA/AAA）
   - その他の要望

2. 収集した情報を基に、以下を含む完全なデザインガイドラインを生成：
   - カラーシステム（プライマリ、セカンダリ、グレースケール、セマンティック）
   - タイポグラフィ（フォント、サイズスケール、行間）
   - スペーシングシステム（8pxベース）
   - 20以上のコンポーネント（Button, Input, Card, Modal等）

3. 出力ファイル：
   - `{プロジェクト名}-design-guideline.md`
   - `{プロジェクト名}-design-tokens.json`

## 参照

詳細な手順は skills/ui-design-guideline/SKILL.md を参照してください。
