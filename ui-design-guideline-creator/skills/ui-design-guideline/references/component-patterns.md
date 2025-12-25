# コンポーネントパターン ベストプラクティス

## コンポーネント設計の原則

### 1. 単一責任の原則
各コンポーネントは1つの明確な目的を持つべき

### 2. 再利用性
異なるコンテキストで使用できるように汎用的に設計

### 3. 構成可能性
小さなコンポーネントを組み合わせて複雑なUIを構築

### 4. アクセシビリティファースト
すべてのコンポーネントはWCAG基準を満たす

## コンポーネントの構造

各コンポーネントは以下を含む：

### 1. Anatomy（構造）
コンポーネントを構成する要素

例：Button
- Container（コンテナ）
- Label（ラベル）
- Icon（アイコン・オプション）
- Ripple Effect（リップルエフェクト・オプション）

### 2. Variants（バリエーション）
デザインのバリエーション

例：Button
- **Primary**: 主要なアクション
- **Secondary**: 二次的なアクション
- **Tertiary**: 最も目立たないアクション
- **Danger**: 危険な操作（削除など）
- **Ghost**: 背景なし
- **Link**: リンクスタイル

### 3. Sizes（サイズ）
```
xs:  height 24px, padding 8px 12px, font-size 12px
sm:  height 32px, padding 12px 16px, font-size 14px
md:  height 40px, padding 12px 20px, font-size 16px (default)
lg:  height 48px, padding 16px 24px, font-size 18px
xl:  height 56px, padding 16px 32px, font-size 20px
```

### 4. States（状態）
すべてのインタラクティブコンポーネントに必要：

- **Default**: デフォルト状態
- **Hover**: マウスオーバー時
- **Focus**: フォーカス時（キーボードナビゲーション）
- **Active**: クリック/タップ時
- **Disabled**: 無効状態
- **Loading**: 処理中
- **Error**: エラー状態（フォーム要素）
- **Success**: 成功状態（フォーム要素）

## 主要コンポーネント

### Button（ボタン）

#### 視覚的フィードバック
```
Default → Hover: 明度を5-10%変更
Hover → Active: 明度をさらに5-10%変更、scale(0.98)
Focus: outline 2px、outline-offset 2px
```

#### アクセシビリティ
- 最小サイズ: 44×44px（タッチターゲット）
- ラベルは必須（アイコンのみの場合はaria-label）
- キーボード操作: Enter/Spaceで実行

### Input（入力フィールド）

#### 構造
- Label（ラベル）
- Input Field（入力領域）
- Helper Text（ヘルパーテキスト・オプション）
- Error Message（エラーメッセージ）
- Icon（アイコン・オプション）

#### 状態による視覚変化
```
Default: border-color gray-300
Focus:   border-color primary-500, outline 2px
Error:   border-color error-500
Success: border-color success-500
Disabled: background gray-100, cursor not-allowed
```

#### アクセシビリティ
- ラベルとinputをid/forで関連付け
- エラーはaria-describedbyで関連付け
- required属性とaria-requiredを使用

### Card（カード）

#### 構造
- Container（コンテナ）
- Header（ヘッダー・オプション）
- Media（画像/動画・オプション）
- Content（コンテンツ）
- Actions（アクション・オプション）

#### バリエーション
- **Elevated**: 影付き（elevation）
- **Outlined**: ボーダー付き
- **Filled**: 背景色付き

#### スペーシング
```
padding: 16px〜24px
gap between sections: 12px〜16px
```

### Modal/Dialog（モーダル）

#### 構造
- Backdrop（背景オーバーレイ）
- Container（コンテナ）
- Header（ヘッダー）
- Body（本体）
- Footer（フッター）
- Close Button（閉じるボタン）

#### アクセシビリティ
- フォーカストラップ（モーダル内でフォーカスを閉じ込める）
- ESCキーで閉じる
- role="dialog"、aria-modal="true"
- aria-labelledbbyでタイトルと関連付け

#### アニメーション
```
Open:  fade-in 200ms, scale 0.95 → 1
Close: fade-out 150ms, scale 1 → 0.95
```

### Dropdown/Select（ドロップダウン）

#### 構造
- Trigger（トリガー）
- Dropdown Menu（ドロップダウンメニュー）
- Options（オプション）
- Divider（区切り線・オプション）

#### キーボード操作
- Arrow Up/Down: オプション間の移動
- Enter/Space: オプションの選択
- ESC: ドロップダウンを閉じる
- Home/End: 最初/最後のオプションへ

### Checkbox & Radio（チェックボックス・ラジオボタン）

#### サイズ
```
sm: 16×16px
md: 20×20px (default)
lg: 24×24px
```

#### タッチターゲット
実際の見た目より大きいタッチエリア（最小44×44px）

#### アクセシビリティ
- label要素で囲む、またはaria-label
- fieldsetでグループ化
- legendでグループのラベル

### Alert/Toast（アラート・トースト）

#### バリエーション
各セマンティックカラーに対応：
- Info（情報）
- Success（成功）
- Warning（警告）
- Error（エラー）

#### 構造
- Icon（アイコン）
- Title（タイトル・オプション）
- Description（説明）
- Close Button（閉じるボタン・オプション）

#### Toastの表示位置
```
top-left, top-center, top-right
bottom-left, bottom-center, bottom-right
```

#### アニメーション
```
Enter: slide-in 300ms + fade-in
Exit:  slide-out 200ms + fade-out
Auto-dismiss: 3-5秒後
```

### Navigation（ナビゲーション）

#### 種類
- **Top Navigation**: ページ上部の水平ナビゲーション
- **Side Navigation**: サイドバーの垂直ナビゲーション
- **Bottom Navigation**: モバイルの下部ナビゲーション
- **Breadcrumb**: パンくずリスト

#### アクセシビリティ
- nav要素を使用
- aria-label="Main navigation"
- 現在のページはaria-current="page"

### Table（テーブル）

#### 構造
- Header（ヘッダー）
- Body（本体）
- Row（行）
- Cell（セル）
- Footer（フッター・オプション）

#### 機能
- ソート可能（クリックでソート）
- フィルタリング
- ページネーション
- 行選択（チェックボックス）

#### レスポンシブ
モバイルでは：
- 水平スクロール
- カード形式に変換
- 重要なカラムのみ表示

### Badge/Tag（バッジ・タグ）

#### 用途
- ステータス表示
- カテゴリー分類
- カウント表示

#### サイズ
```
sm: padding 2px 8px, font-size 12px
md: padding 4px 12px, font-size 14px
lg: padding 6px 16px, font-size 16px
```

## コンポーネント間の一貫性

### スペーシング
すべてのコンポーネントで8pxベースのスペーシングを使用

### ボーダー半径
```
sm: 4px  (小さいコンポーネント)
md: 8px  (標準)
lg: 12px (大きいコンポーネント)
xl: 16px (カード、モーダル)
full: 9999px (丸いボタン、アバター)
```

### 影（Elevation）
```
sm:  0 1px 2px rgba(0,0,0,0.05)
md:  0 4px 6px rgba(0,0,0,0.1)
lg:  0 10px 15px rgba(0,0,0,0.1)
xl:  0 20px 25px rgba(0,0,0,0.15)
2xl: 0 25px 50px rgba(0,0,0,0.25)
```

### トランジション
```
fast: 150ms (小さい変化)
base: 200ms (標準)
slow: 300ms (大きい変化)
```

イージング：
```
ease-in-out (標準)
ease-out (入場アニメーション)
ease-in (退場アニメーション)
```

## 参考デザインシステム
- **Material Design**: 包括的なコンポーネントライブラリ
- **Ant Design**: エンタープライズ向けコンポーネント
- **Chakra UI**: アクセシブルなコンポーネントの良い例
- **Radix UI**: ヘッドレスコンポーネントのベストプラクティス
