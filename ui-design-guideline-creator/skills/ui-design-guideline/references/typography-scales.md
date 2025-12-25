# タイポグラフィスケール ベストプラクティス

## フォントファミリー

### システムフォントスタック（推奨）
レスポンスが速く、すべてのデバイスで利用可能：

#### Sans-serif（ゴシック体）
```css
font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
             "Helvetica Neue", Arial, "Noto Sans", sans-serif,
             "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol",
             "Noto Color Emoji";
```

#### 日本語対応
```css
font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
             "Helvetica Neue", Arial, "Hiragino Kaku Gothic ProN",
             "Hiragino Sans", Meiryo, sans-serif;
```

#### Serif（明朝体）
```css
font-family: Georgia, Cambria, "Times New Roman", Times, serif;
```

#### Monospace（等幅）
```css
font-family: Menlo, Monaco, Consolas, "Liberation Mono",
             "Courier New", monospace;
```

## フォントサイズスケール

### Modular Scale方式（1.25倍率）
数学的に調和のとれたスケール：

```
xs:   0.64rem  (10.24px @ 16px base)
sm:   0.8rem   (12.8px)
base: 1rem     (16px) ← ベースサイズ
lg:   1.25rem  (20px)
xl:   1.563rem (25px)
2xl:  1.953rem (31.25px)
3xl:  2.441rem (39px)
4xl:  3.052rem (48.8px)
5xl:  3.815rem (61px)
6xl:  4.768rem (76px)
```

### 見出しサイズ
```
H1: 2.441rem (3xl) - 最も重要な見出し
H2: 1.953rem (2xl) - セクション見出し
H3: 1.563rem (xl)  - サブセクション見出し
H4: 1.25rem  (lg)  - 小見出し
H5: 1rem     (base)- 強調テキスト
H6: 0.8rem   (sm)  - 最小見出し
```

### 本文テキスト
```
body-lg:   1.125rem (18px) - 読みやすさ重視
body-base: 1rem     (16px) - 標準
body-sm:   0.875rem (14px) - コンパクト
caption:   0.75rem  (12px) - キャプション、ラベル
```

## 行間（Line Height）

### 基本原則
- **見出し**: 1.2〜1.4（タイトなレイアウト）
- **本文**: 1.5〜1.75（可読性重視）
- **キャプション**: 1.4〜1.5（バランス）

### 具体的な値
```css
leading-tight:  1.25  /* 見出し用 */
leading-snug:   1.375
leading-normal: 1.5   /* 本文デフォルト */
leading-relaxed: 1.625
leading-loose:  2     /* 余裕のあるレイアウト */
```

## フォントウェイト

### 推奨される重さ
```
thin:       100
extralight: 200
light:      300
normal:     400  ← 本文デフォルト
medium:     500
semibold:   600  ← 見出し、強調
bold:       700
extrabold:  800
black:      900
```

### 使用ガイドライン
- **本文**: 400 (normal)
- **強調**: 500-600 (medium-semibold)
- **見出し**: 600-700 (semibold-bold)
- **超強調**: 800-900 (extrabold-black)

## 字間（Letter Spacing）

### トラッキング
```css
tracking-tighter: -0.05em  /* 大きな見出し用 */
tracking-tight:   -0.025em
tracking-normal:  0        /* デフォルト */
tracking-wide:    0.025em  /* 小さいテキスト用 */
tracking-wider:   0.05em
tracking-widest:  0.1em    /* 全て大文字の場合 */
```

### 使用例
- 大きな見出し（H1-H2）: `tracking-tight`
- 通常テキスト: `tracking-normal`
- 小さなテキスト、ラベル: `tracking-wide`
- 大文字テキスト: `tracking-wider`〜`tracking-widest`

## レスポンシブタイポグラフィ

### フルードタイポグラフィ
画面サイズに応じて滑らかにスケール：

```css
/* H1の例 */
font-size: clamp(2rem, 5vw, 3.815rem);

/* 本文の例 */
font-size: clamp(1rem, 2.5vw, 1.125rem);
```

### ブレークポイント別
```css
/* モバイル */
h1 { font-size: 1.953rem; }

/* タブレット (768px+) */
@media (min-width: 768px) {
  h1 { font-size: 2.441rem; }
}

/* デスクトップ (1024px+) */
@media (min-width: 1024px) {
  h1 { font-size: 3.052rem; }
}
```

## テキストカラー

### 階層的な色の濃さ
```
text-primary:   gray-900 (最も重要、見出し)
text-secondary: gray-700 (本文)
text-tertiary:  gray-500 (補足情報)
text-disabled:  gray-400 (無効状態)
```

## アクセシビリティ

### 最小サイズ
- **本文**: 16px以上推奨
- **キャプション**: 12px以下は避ける
- **タッチターゲット内のテキスト**: 14px以上

### コントラスト
- color-systems.mdを参照

## 参考デザインシステム
- **Material Design**: 包括的なタイポグラフィシステム
- **Tailwind CSS**: 実用的なスケールとユーティリティ
- **IBM Carbon**: 企業向けタイポグラフィの良い例
- **Apple Human Interface Guidelines**: モバイル向けタイポグラフィ
