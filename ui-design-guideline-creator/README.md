# UIデザインガイドライン作成プラグイン

包括的なUIデザインガイドラインを対話的に作成するClaude Code プラグインです。

## 概要

このプラグインは、最小限の質問（6つ程度）から、カラーシステム、タイポグラフィ、スペーシング、20以上のUIコンポーネントを含む完全なデザインシステムを自動生成します。

### 主な機能

- **対話的な生成**: 必要最小限の質問でカスタマイズされたガイドラインを作成
- **🆕 URL解析機能**: 既存サイトのURLを渡すだけで、デザインを自動解析してガイドラインを生成
- **包括的なシステム**: 50-100ページ相当のドキュメントを生成
- **ベストプラクティス準拠**: Material Design、Ant Design、Chakra UIなどの実績あるデザインシステムを参考
- **アクセシビリティファースト**: WCAG 2.1 AA/AAA準拠
- **フレームワーク非依存**: どんな技術スタックでも利用可能
- **複数の出力形式**: Markdown + JSONデザイントークン

## 生成されるもの

### 1. デザイン基盤

- **カラーシステム**
  - プライマリ・セカンダリカラーパレット（各9段階）
  - グレースケール（9段階）
  - セマンティックカラー（Success, Warning, Error, Info）
  - 用途別カラートークン

- **タイポグラフィ**
  - フォントファミリー（システムフォントスタック）
  - フォントサイズスケール（10段階）
  - 見出しスタイル（H1-H6）
  - フォントウェイト、行間、字間

- **スペーシングシステム**
  - 8pxベースのスペーシングスケール
  - 12カラムグリッドシステム
  - レスポンシブブレークポイント

### 2. UIコンポーネント（20以上）

各コンポーネントには以下が含まれます：
- 構造（Anatomy）
- バリエーション（Variants）
- サイズ（Sizes）
- 状態（States）
- 使用ガイドライン（Do/Don't）
- コード例（HTML/CSS、React、Vue）
- アクセシビリティ要件

**含まれるコンポーネント**：
- Button, Input, Textarea, Select, Checkbox, Radio, Switch
- Card, Modal, Dialog, Drawer, Tooltip, Popover
- Alert, Toast, Badge, Tag
- Avatar, Navigation, Breadcrumb, Tabs, Pagination
- Table, List, Divider

### 3. ドキュメント

- デザイン原則
- レイアウトガイドライン
- アイコン使用ガイドライン
- アニメーション/モーションガイドライン
- アクセシビリティチェックリスト
- ベストプラクティス

### 4. 出力ファイル

1. **Markdownドキュメント**: `{ProjectName}-design-guideline.md`
   - 完全なデザインガイドライン（50-100ページ相当）

2. **JSONデザイントークン**: `{ProjectName}-design-tokens.json`
   - プログラムから利用可能なデザイントークン

## インストール方法

### 方法1: 手動インストール

1. このリポジトリをクローン：
```bash
git clone https://github.com/your-username/ui-design-guideline-creator.git
```

2. Claudeのプラグインディレクトリにコピー：
```bash
cp -r ui-design-guideline-creator ~/.claude/plugins/
```

3. Claude Codeを再起動

### 方法2: シンボリックリンク（開発用）

```bash
ln -s /path/to/ui-design-guideline-creator ~/.claude/plugins/ui-design-guideline-creator
```

## 使用方法

### 基本的な使い方

#### パターン1: ゼロから作成

Claude Codeで以下のように依頼：

```
UIデザインガイドラインを作成してください
```

または

```
新しいプロジェクトのデザインシステムを作成してください
```

#### パターン2: 🆕 既存サイトから作成（URL解析）

既存のWebサイトのデザインを模したガイドラインを作成：

```
https://example.com のデザインガイドラインを作成してください
```

または

```
このサイトのデザインシステムを参考にガイドラインを作成:
https://your-favorite-site.com
```

**URL解析の流れ**：
1. プラグインがサイトを自動解析
2. カラー、フォント、スペーシングなどを抽出
3. 抽出した要素を提示して確認
4. 確認後、包括的なガイドラインを生成

### 対話的な質問

プラグインは以下の質問をします：

1. **🆕 参考サイトのURL（任意）**: 参考にしたいWebサイトのURL
2. **プロジェクト名**: デザインガイドラインの名前
3. **対象プラットフォーム**: Web、iOS、Android、React Native、Flutterなど
4. **プライマリブランドカラー**: HEXコード（例: #3B82F6）※URLから自動抽出も可
5. **既存リソース**: 既存のデザインファイルやガイドラインの有無
6. **アクセシビリティレベル**: WCAG 2.1 AAまたはAAA
7. **その他の要望**: 特別な要件や重視したいポイント

### 生成例

#### 例1: ゼロから作成

**入力例**：
```
プロジェクト名: MyApp
対象プラットフォーム: Web
プライマリブランドカラー: #6366F1
アクセシビリティレベル: WCAG 2.1 AA
```

**生成されるファイル**：
- `MyApp-design-guideline.md`（約50-100ページ）
- `MyApp-design-tokens.json`

#### 例2: 🆕 URL解析から作成

**入力例**：
```
参考サイトURL: https://stripe.com
プロジェクト名: MyPaymentApp
対象プラットフォーム: Web
```

**自動抽出される情報**：
- プライマリカラー: #635BFF（Stripeのブランドカラー）
- フォント: -apple-system, BlinkMacSystemFont, ...
- スペーシング: 8pxベース
- ボタンスタイル: 高さ40px、border-radius 6px

**生成されるファイル**：
- `MyPaymentApp-design-guideline.md`（Stripeライクなデザイン）
- `MyPaymentApp-design-tokens.json`

## プラグイン構造

```
ui-design-guideline-creator/
├── .claude-plugin/
│   └── plugin.json              # プラグインメタデータ
├── skills/
│   └── ui-design-guideline/
│       ├── SKILL.md             # メインスキル定義
│       ├── references/          # ベストプラクティス参考資料
│       │   ├── color-systems.md
│       │   ├── typography-scales.md
│       │   ├── spacing-systems.md
│       │   ├── component-patterns.md
│       │   ├── accessibility.md
│       │   └── 🆕 website-analysis.md   # サイト解析ガイド
│       └── templates/           # 生成用テンプレート
│           ├── guideline-template.md
│           ├── component-template.md
│           └── design-tokens.json
└── README.md                    # このファイル
```

## カスタマイズ

### リファレンスファイルの編集

`skills/ui-design-guideline/references/`内のファイルを編集することで、生成されるガイドラインのベストプラクティスをカスタマイズできます。

### テンプレートの編集

`skills/ui-design-guideline/templates/`内のテンプレートを編集することで、出力形式をカスタマイズできます。

### スキルロジックの編集

`skills/ui-design-guideline/SKILL.md`を編集することで、質問内容や生成ロジックをカスタマイズできます。

## 技術仕様

### 🆕 URL解析
- WebFetchツールによる自動サイト解析
- カラー、フォント、スペーシングの自動抽出
- CSS/HTMLパース
- 不足要素の自動補完

### カラーシステム
- HSL色空間での明度調整
- 9段階スケール（50-900）
- WCAG 2.1準拠のコントラスト比
- URL解析からのカラー抽出対応

### タイポグラフィ
- Modular Scale方式（1.25倍率）
- システムフォントスタック
- レスポンシブタイポグラフィ対応
- URL解析からのフォント情報抽出対応

### スペーシング
- 8pxベースシステム
- 12カラムグリッド
- レスポンシブブレークポイント
- URL解析からのスペーシング値抽出対応

### アクセシビリティ
- WCAG 2.1 AA/AAA準拠
- キーボードナビゲーション
- スクリーンリーダー対応
- ARIAベストプラクティス
- URL解析時の自動コントラスト比チェック

## ベストプラクティス

このプラグインは、以下の実績あるデザインシステムのベストプラクティスを参考にしています：

- **Material Design** (Google)
- **Ant Design** (Alibaba)
- **Chakra UI**
- **Tailwind CSS**
- **Apple Human Interface Guidelines**
- **IBM Carbon**
- **Radix UI**

## トラブルシューティング

### プラグインが認識されない

1. プラグインディレクトリが正しいか確認：`~/.claude/plugins/ui-design-guideline-creator`
2. `plugin.json`が存在するか確認
3. Claude Codeを再起動

### 生成が途中で止まる

- 大量のコンテンツを生成するため、処理に時間がかかる場合があります
- Claudeのコンテキスト制限に達した場合は、セクションごとに分けて生成を依頼

### カラーがうまく生成されない

- HEXコードが正しい形式か確認（例: #3B82F6）
- リファレンスファイル `references/color-systems.md` を確認

### 🆕 URL解析がうまくいかない

- URLが正しい形式か確認（https://から始まる完全なURL）
- サイトが公開されているか確認（認証が必要なページは解析不可）
- WebFetchツールの権限が許可されているか確認
- 複雑なSPA（Single Page Application）の場合、一部の情報が取得できない可能性があります

## 貢献

バグ報告、機能リクエスト、プルリクエストを歓迎します。

## ライセンス

MIT License

## 作者

Your Name

## 関連リソース

- [Claude Code ドキュメント](https://code.claude.com/docs)
- [WCAG 2.1 ガイドライン](https://www.w3.org/WAI/WCAG21/quickref/)
- [Material Design](https://material.io/design)
- [Ant Design](https://ant.design/)
- [Chakra UI](https://chakra-ui.com/)

## 変更履歴

### バージョン 1.1.0 (2025-12-25)
- 🆕 **URL解析機能を追加**: 既存サイトのデザインを自動抽出
- `references/website-analysis.md`を追加
- SKILL.mdにURL解析フローを追加
- README.mdにURL解析の使用例を追加

### バージョン 1.0.0 (2025-12-25)
- 初版リリース
- 基本的なデザインシステム生成機能
- 20以上のコンポーネント対応
- WCAG 2.1 AA/AAA準拠
