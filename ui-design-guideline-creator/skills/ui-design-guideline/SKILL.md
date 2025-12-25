---
name: ui-design-guideline
description: 包括的なUIデザインガイドラインを対話的に作成します。最小限の質問から、カラーシステム、タイポグラフィ、スペーシング、20以上のコンポーネントを含む完全なデザインシステムを生成します。URLを渡すと、既存サイトのデザインを解析して、それを模したガイドラインを作成できます。
---

# UIデザインガイドライン作成スキル

このスキルは、ユーザーと対話しながら包括的なUIデザインガイドラインを作成します。

## 使用タイミング

以下の場合にこのスキルを起動してください：
- ユーザーが「UIデザインガイドライン」「デザインシステム」「スタイルガイド」の作成を依頼した時
- 新しいプロジェクトのデザイン標準を作成する時
- 既存のデザインを体系化したい時
- **URLを渡して既存サイトのデザインを模したい時**

## 対話フェーズ

### ステップ0: URL入力の確認（オプション）

**ユーザーがURLを提供した場合**、まずそのサイトを解析します：

1. **WebFetchツールを使用**して、サイトのデザインを解析
   - `references/website-analysis.md`のガイドに従って解析
   - 以下を抽出：
     - カラーパレット（プライマリ、セカンダリ、グレースケール）
     - タイポグラフィ（フォント、サイズ、ウェイト）
     - スペーシング（マージン、パディング、基準単位）
     - コンポーネントスタイル（ボタン、入力、カード等）
     - 視覚スタイル（ボーダー半径、影、トランジション）

2. **解析結果を保存**
   - 抽出した値を後の生成フェーズで使用
   - 不足している要素はベストプラクティスで補完

3. **ユーザーに確認**
   - 「このサイトから以下のデザイン要素を抽出しました」
   - 主要な色、フォント、スペーシングを提示
   - 「これをベースにガイドラインを作成しますか？」

**URLが提供されない場合**、通常の対話フェーズに進みます。

### 質問内容

まず、ユーザーに以下の質問をして、必要最小限の情報を収集してください。AskUserQuestionツールを使用して、一度にすべての質問を行ってください。

1. **参考サイトのURL（新規追加・オプション）**
   - 質問: 「参考にしたいWebサイトのURLはありますか？（任意）」
   - デフォルト: なし（オプション）
   - URLが提供された場合は、ステップ0のサイト解析を実行

2. **プロジェクト名**
   - 質問: 「このデザインガイドラインのプロジェクト名を教えてください」
   - デフォルト: なし（必須）

3. **対象プラットフォーム**
   - 質問: 「対象プラットフォームは何ですか？」
   - 選択肢:
     - Web（デスクトップ・モバイルブラウザ）
     - iOS
     - Android
     - React Native
     - Flutter
     - その他（カスタム入力）

4. **プライマリブランドカラー**
   - 質問: 「プライマリブランドカラーがあれば教えてください（例: #3B82F6）」
   - デフォルト: URL解析で抽出した色、または #3B82F6（青）
   - URLから抽出した場合は、その色を提示して確認

5. **既存のデザインリソース**
   - 質問: 「既存のデザインファイル、ブランドガイドライン、または参考にしたいデザインシステムはありますか？」
   - デフォルト: なし（オプション）

6. **アクセシビリティレベル**
   - 質問: 「目標とするWCAG準拠レベルは？」
   - 選択肢:
     - WCAG 2.1 AA（推奨）
     - WCAG 2.1 AAA（最高レベル）
   - デフォルト: WCAG 2.1 AA

7. **その他の要望**
   - 質問: 「その他、特別な要件や重視したいポイントはありますか？」
   - デフォルト: なし（オプション）

## サイト解析の詳細手順（URL提供時）

URLが提供された場合、以下の手順でサイトを解析します：

### 解析プロンプト

WebFetchツールで以下のプロンプトを使用：

```
このWebサイトのデザインシステムを詳しく分析してください。以下の情報をJSON形式で抽出してください：

1. カラーパレット
   - プライマリカラー（最も使用されている色のHEXコード）
   - セカンダリカラー（2番目に使用されている色）
   - アクセントカラー（ボタンやリンクの色）
   - テキストカラー（本文、見出しなど）
   - 背景カラー

2. タイポグラフィ
   - フォントファミリー（本文用、見出し用）
   - フォントサイズ（H1-H6、本文、キャプション）
   - フォントウェイト（使用されているウェイト値）
   - 行間（line-height）

3. スペーシング
   - よく使用されるパディング値（上位5つ）
   - よく使用されるマージン値（上位5つ）
   - スペーシングの基準単位（4px, 8px, など）

4. コンポーネントスタイル
   - ボタン（高さ、パディング、ボーダー半径、色）
   - 入力フィールド（高さ、パディング、ボーダースタイル）
   - カード（パディング、ボーダー半径、影）

5. 視覚スタイル
   - ボーダー半径（よく使用される値）
   - 影（box-shadow）
   - トランジション（duration、easing）

可能な限り具体的な値（px、HEXコードなど）で回答してください。
```

### 解析結果の処理

1. **カラーの正規化**
   - HEX形式に統一
   - 明度スケール（50-900）を生成

2. **タイポグラフィの正規化**
   - pxをremに変換
   - Modular Scaleに調整

3. **スペーシングの正規化**
   - 8pxベースに統一
   - 不足値を補完

4. **不足要素の補完**
   - 抽出できなかった要素はベストプラクティスで補完

## 生成フェーズ

質問への回答を収集したら、以下の手順で包括的なUIデザインガイドラインを生成してください。

### ステップ1: プロジェクト情報の設定

収集した情報を変数として保存：
```
PROJECT_NAME: ユーザー入力
PLATFORM: ユーザー選択
PRIMARY_COLOR: URL解析結果 または ユーザー入力 または デフォルト
REFERENCE_URL: 提供されたURL（あれば）
ACCESSIBILITY_LEVEL: ユーザー選択またはデフォルト
DATE: 今日の日付
```

### ステップ2: カラーシステムの生成

**URLから解析した場合**：
- 解析結果のプライマリカラーを使用
- 解析結果のセカンダリカラーを使用（あれば）
- 不足している明度スケールを補完

**通常の場合**：

`references/color-systems.md`のベストプラクティスに基づいて：

1. **プライマリカラーパレットの生成**
   - ユーザー提供のプライマリカラー（またはデフォルト）を基準に
   - 50-900の明度スケール（9段階）を生成
   - HSL色空間で明度を調整

2. **セカンダリカラーの生成**
   - プライマリカラーの補色（色相+180度）
   - または類似色（色相+30-60度）
   - 同じく50-900のスケール

3. **グレースケール**
   - 標準的な9段階グレースケールを使用
   - `references/color-systems.md`の推奨値

4. **セマンティックカラー**
   - Success: #10B981（緑）ベース
   - Warning: #F59E0B（オレンジ）ベース
   - Error: #EF4444（赤）ベース
   - Info: #3B82F6（青）ベース
   - それぞれ50-900のスケール

5. **用途別カラートークン**
   ```
   TEXT_PRIMARY: gray-900
   TEXT_SECONDARY: gray-700
   TEXT_TERTIARY: gray-500
   TEXT_DISABLED: gray-400
   BG_PRIMARY: #FFFFFF
   BG_SECONDARY: gray-50
   BG_TERTIARY: gray-100
   BORDER_DEFAULT: gray-300
   BORDER_FOCUS: primary-500
   BORDER_ERROR: error-500
   ```

### ステップ3: タイポグラフィの定義

`references/typography-scales.md`のベストプラクティスに基づいて：

1. **フォントファミリー**
   - プラットフォームに応じたシステムフォントスタック
   - Web: `-apple-system, BlinkMacSystemFont, "Segoe UI"...`
   - 日本語対応も含める

2. **フォントサイズスケール**
   - Modular Scale（1.25倍率）を使用
   - xs, sm, base, lg, xl, 2xl, 3xl, 4xl, 5xl, 6xl

3. **見出しスタイル**
   - H1〜H6の定義
   - サイズ、ウェイト、行間、マージン

4. **本文テキスト**
   - body-lg, body-base, body-sm, caption

5. **フォントウェイト**
   - 100-900の標準値

6. **行間・字間**
   - leading: tight, snug, normal, relaxed, loose
   - tracking: tighter, tight, normal, wide, wider, widest

### ステップ4: スペーシングシステムの定義

`references/spacing-systems.md`のベストプラクティスに基づいて：

1. **基準単位**
   - 8pxベースシステム
   - 0, 0.5, 1, 1.5, 2, ... 32単位

2. **グリッドシステム**
   - 12カラムグリッド
   - ブレークポイント別の設定（モバイル、タブレット、デスクトップ）

3. **コンテナ幅**
   - sm: 640px, md: 768px, lg: 1024px, xl: 1280px, 2xl: 1536px

4. **ブレークポイント**
   - xs, sm, md, lg, xl, 2xl

### ステップ5: コンポーネントライブラリの生成

`references/component-patterns.md`と`templates/component-template.md`を使用して、以下のコンポーネントを生成：

#### 必須コンポーネント（20+）

1. **Button（ボタン）**
   - Variants: Primary, Secondary, Tertiary, Danger, Ghost, Link
   - Sizes: xs, sm, md, lg, xl
   - States: Default, Hover, Focus, Active, Disabled, Loading

2. **Input（入力フィールド）**
   - Variants: Default, Filled, Outlined
   - Sizes: sm, md, lg
   - States: Default, Focus, Error, Success, Disabled

3. **Textarea（複数行入力）**
   - 同上

4. **Select（選択）**
   - ドロップダウン選択
   - States: Default, Focus, Open, Disabled

5. **Checkbox（チェックボックス）**
   - Sizes: sm, md, lg
   - States: Unchecked, Checked, Indeterminate, Disabled

6. **Radio（ラジオボタン）**
   - Sizes: sm, md, lg
   - States: Unchecked, Checked, Disabled

7. **Switch（スイッチ）**
   - Sizes: sm, md, lg
   - States: Off, On, Disabled

8. **Card（カード）**
   - Variants: Elevated, Outlined, Filled
   - 構造: Header, Media, Content, Actions

9. **Modal/Dialog（モーダル）**
   - Sizes: sm, md, lg, xl, fullscreen
   - 構造: Backdrop, Container, Header, Body, Footer, Close

10. **Drawer（ドロワー）**
    - Positions: Left, Right, Top, Bottom
    - Sizes: sm, md, lg

11. **Tooltip（ツールチップ）**
    - Positions: Top, Bottom, Left, Right

12. **Popover（ポップオーバー）**
    - Positions: Top, Bottom, Left, Right

13. **Alert（アラート）**
    - Variants: Info, Success, Warning, Error
    - Closable: Yes/No

14. **Toast（トースト通知）**
    - Variants: Info, Success, Warning, Error
    - Positions: 6種類（top-left, top-center, top-right, etc.）

15. **Badge（バッジ）**
    - Variants: Primary, Secondary, Success, Warning, Error
    - Sizes: sm, md, lg

16. **Tag（タグ）**
    - 同上 + Closable

17. **Avatar（アバター）**
    - Sizes: xs, sm, md, lg, xl
    - Variants: Image, Initials, Icon

18. **Navigation（ナビゲーション）**
    - Types: Top Nav, Side Nav, Bottom Nav, Breadcrumb

19. **Tabs（タブ）**
    - Variants: Line, Enclosed, Pills

20. **Pagination（ページネーション）**
    - Variants: Simple, Full

21. **Table（テーブル）**
    - Features: Sortable, Filterable, Selectable

22. **List（リスト）**
    - Variants: Unordered, Ordered, Description

23. **Divider（区切り線）**
    - Orientations: Horizontal, Vertical

各コンポーネントは`templates/component-template.md`の構造に従って生成してください。

### ステップ6: その他のセクション

1. **レイアウト**
   - レスポンシブデザインガイドライン
   - グリッドレイアウト例

2. **アイコン**
   - アイコンサイズ（16px, 20px, 24px, 32px）
   - 使用ガイドライン

3. **アニメーション**
   - トランジション（150ms, 200ms, 300ms）
   - イージング（ease-in-out, ease-out, ease-in）
   - 使用ガイドライン

4. **アクセシビリティ**
   - `references/accessibility.md`を参照
   - WCAG準拠レベルの詳細
   - キーボードナビゲーション
   - スクリーンリーダー対応
   - カラーコントラスト要件

5. **ベストプラクティス**
   - Do's/Don'ts
   - コード例

## 出力形式

### 1. Markdownドキュメント

`templates/guideline-template.md`をベースに、すべてのプレースホルダー（{{...}}）を実際の値で置き換えて、完全なMarkdownドキュメントを生成してください。

ファイル名: `{{PROJECT_NAME}}-design-guideline.md`

### 2. デザイントークンJSON

`templates/design-tokens.json`をベースに、生成したカラー、タイポグラフィ、スペーシングの値を含むJSONファイルを生成してください。

ファイル名: `{{PROJECT_NAME}}-design-tokens.json`

### 3. 個別コンポーネントファイル（オプション）

ユーザーが希望する場合、各コンポーネントを個別のMarkdownファイルとして生成することもできます。

ファイル名: `components/{{COMPONENT_NAME}}.md`

## 生成後の確認

1. すべてのカラーコントラスト比がWCAG基準を満たしているか確認
2. タイポグラフィスケールが調和しているか確認
3. スペーシングが8pxベースで一貫しているか確認
4. すべてのコンポーネントにアクセシビリティ情報が含まれているか確認

## ユーザーへの提示

生成が完了したら、以下を伝えてください：

1. 生成されたファイルのリスト
2. ガイドラインの概要（カラー数、コンポーネント数など）
3. 次のステップの提案：
   - 特定のコンポーネントの詳細化
   - 追加コンポーネントの作成
   - Figma/Storybook等への変換
   - 実装例の追加

## 例

### 質問フェーズの例

```
プロジェクト名: MyApp
対象プラットフォーム: Web
プライマリブランドカラー: #6366F1（インディゴ）
既存リソース: なし
アクセシビリティレベル: WCAG 2.1 AA
その他の要望: モダンで洗練されたデザイン
```

### 生成されるファイル

1. `MyApp-design-guideline.md`（50-100ページ相当）
2. `MyApp-design-tokens.json`

## 注意事項

- すべての色はアクセシビリティ基準を満たすこと
- フレームワーク非依存のコード例を提供すること
- 日本語と英語の両方に対応すること
- 実際のデザインシステム（Material Design, Ant Design等）のベストプラクティスを参考にすること

## リファレンスファイル

生成時に以下のリファレンスファイルを必ず参照してください：

- `references/color-systems.md`: カラーシステムのベストプラクティス
- `references/typography-scales.md`: タイポグラフィのベストプラクティス
- `references/spacing-systems.md`: スペーシングのベストプラクティス
- `references/component-patterns.md`: コンポーネントパターン
- `references/accessibility.md`: アクセシビリティガイドライン
- `references/website-analysis.md`: **Webサイトデザイン解析ガイド（URL提供時に使用）**

## テンプレートファイル

生成時に以下のテンプレートを使用してください：

- `templates/guideline-template.md`: メインガイドラインの構造
- `templates/component-template.md`: 各コンポーネントの構造
- `templates/design-tokens.json`: デザイントークンの構造

これらのファイルの内容を必ず読み込んで、適切に活用してください。
