# スペーシングシステム ベストプラクティス

## 基準単位

### 8pxベースシステム（推奨）
8pxを基準とすることで、デバイスピクセル比に対応しやすく、デザインの一貫性が保たれます。

```
0:    0px
0.5:  4px   (0.5 unit)
1:    8px   (1 unit)
1.5:  12px  (1.5 unit)
2:    16px  (2 unit)
2.5:  20px  (2.5 unit)
3:    24px  (3 unit)
3.5:  28px  (3.5 unit)
4:    32px  (4 unit)
5:    40px  (5 unit)
6:    48px  (6 unit)
7:    56px  (7 unit)
8:    64px  (8 unit)
9:    72px  (9 unit)
10:   80px  (10 unit)
11:   88px  (11 unit)
12:   96px  (12 unit)
14:   112px (14 unit)
16:   128px (16 unit)
20:   160px (20 unit)
24:   192px (24 unit)
28:   224px (28 unit)
32:   256px (32 unit)
```

### 4pxベースシステム（代替）
より細かい調整が必要な場合：
```
0, 4px, 8px, 12px, 16px, 20px, 24px, 28px, 32px...
```

## マージンとパディング

### 使用ガイドライン

#### 小さいコンポーネント
- **パディング**: 8px〜16px (1-2 unit)
- **アイテム間**: 4px〜12px (0.5-1.5 unit)

例：ボタン、入力フィールド、タグ

#### 中サイズコンポーネント
- **パディング**: 16px〜24px (2-3 unit)
- **アイテム間**: 12px〜24px (1.5-3 unit)

例：カード、モーダル、フォームセクション

#### 大きいコンポーネント
- **パディング**: 24px〜48px (3-6 unit)
- **アイテム間**: 24px〜48px (3-6 unit)

例：ページセクション、コンテナ

### レスポンシブスペーシング
画面サイズに応じて調整：

```css
/* モバイル */
.container { padding: 16px; }
.section { margin-bottom: 24px; }

/* タブレット (768px+) */
@media (min-width: 768px) {
  .container { padding: 24px; }
  .section { margin-bottom: 32px; }
}

/* デスクトップ (1024px+) */
@media (min-width: 1024px) {
  .container { padding: 32px; }
  .section { margin-bottom: 48px; }
}
```

## グリッドシステム

### 12カラムグリッド（推奨）
柔軟性が高く、様々なレイアウトに対応：

```
columns: 12
gutter: 24px (モバイル: 16px)
margin: 24px (モバイル: 16px)
```

#### ブレークポイント別の設定

**モバイル (< 640px)**
```
columns: 4
gutter: 16px
margin: 16px
max-width: 100%
```

**タブレット (640px - 1024px)**
```
columns: 8
gutter: 24px
margin: 32px
max-width: 768px
```

**デスクトップ (1024px - 1280px)**
```
columns: 12
gutter: 24px
margin: 48px
max-width: 1024px
```

**ワイドスクリーン (1280px+)**
```
columns: 12
gutter: 32px
margin: 64px
max-width: 1280px
```

### グリッドの使用例

#### 2カラムレイアウト
- モバイル: 各カラム4/4（縦積み）
- タブレット: 各カラム4/8
- デスクトップ: 各カラム6/12

#### 3カラムレイアウト
- モバイル: 各カラム4/4（縦積み）
- タブレット: 各カラム4/8（2+1）
- デスクトップ: 各カラム4/12

#### サイドバー付きレイアウト
- モバイル: メイン4/4、サイドバー4/4（縦積み）
- タブレット: メイン6/8、サイドバー2/8
- デスクトップ: メイン9/12、サイドバー3/12

## コンテナ幅

### 最大幅の設定
```
sm:  640px  /* 小さいデバイス */
md:  768px  /* タブレット */
lg:  1024px /* ラップトップ */
xl:  1280px /* デスクトップ */
2xl: 1536px /* 大型ディスプレイ */
```

### コンテンツ幅
読みやすさを考慮した最大幅：
```
prose: 65ch (約650-700px)
```
※ chは文字幅の単位。長い行は読みづらくなるため、45-75文字を推奨

## 垂直リズム

### 行送りとマージンの調和
タイポグラフィとスペーシングを調和させる：

```
base-line-height: 1.5
base-spacing: 24px (1.5 × 16px)
```

#### 見出しのマージン
```css
h1 {
  margin-top: 48px;    /* 3 × base-spacing */
  margin-bottom: 24px; /* 1.5 × base-spacing */
}

h2 {
  margin-top: 40px;    /* 2.5 × base-spacing */
  margin-bottom: 16px; /* 1 × base-spacing */
}

h3 {
  margin-top: 32px;    /* 2 × base-spacing */
  margin-bottom: 16px;
}

p {
  margin-bottom: 16px; /* 1 × base-spacing */
}
```

## タッチターゲット

### 最小サイズ（モバイル）
- **推奨**: 44×44px (Apple HIG)
- **最小**: 48×48px (Material Design)

### スペーシング
- タッチターゲット間: 最低8px
- 推奨: 16px以上

## Z-index スケール

階層管理のための標準値：
```
dropdown:  1000
sticky:    1020
fixed:     1030
modal-backdrop: 1040
modal:     1050
popover:   1060
tooltip:   1070
toast:     1080
```

## アクセシビリティ考慮事項

### フォーカスインジケーター
```css
:focus {
  outline: 2px solid primary-500;
  outline-offset: 2px;
}
```

### スキップリンク
```css
.skip-link {
  position: absolute;
  top: 8px;
  left: 8px;
  padding: 8px 16px;
}
```

## 参考デザインシステム
- **Material Design**: 包括的なスペーシングシステム
- **Tailwind CSS**: 8pxベースの実用的なスケール
- **Bootstrap**: グリッドシステムの標準
- **Apple HIG**: タッチターゲットのベストプラクティス
