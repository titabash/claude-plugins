# アクセシビリティ ベストプラクティス

## WCAG（Web Content Accessibility Guidelines）

### 準拠レベル
- **Level A**: 最低限の要件（必須）
- **Level AA**: 推奨レベル（多くの組織が目標とする）
- **Level AAA**: 最高レベル（すべてに適用は困難）

### 4つの原則（POUR）

#### 1. Perceivable（知覚可能）
情報とUIコンポーネントは、ユーザーが知覚できる方法で提示される必要がある

#### 2. Operable（操作可能）
UIコンポーネントとナビゲーションは操作可能でなければならない

#### 3. Understandable（理解可能）
情報とUIの操作は理解可能でなければならない

#### 4. Robust（堅牢）
コンテンツは、支援技術を含む様々なユーザーエージェントで解釈できる必要がある

## カラーとコントラスト

### コントラスト比（WCAG 2.1）

#### Level AA（推奨）
- **通常テキスト**: 4.5:1以上
- **大きなテキスト**（18pt以上または14pt太字以上）: 3:1以上
- **UIコンポーネント**: 3:1以上
- **グラフィックオブジェクト**: 3:1以上

#### Level AAA（理想）
- **通常テキスト**: 7:1以上
- **大きなテキスト**: 4.5:1以上

### カラーの使用

#### 色だけに依存しない
❌ 悪い例：
```
「赤い項目が必須です」
```

✅ 良い例：
```
「*マークが付いた項目が必須です」
+ 赤色の視覚的な強調
```

#### カラーブラインドネス対応
- 赤と緑だけで区別しない
- アイコンやパターンを併用
- カラーブラインドシミュレータでテスト

### ツール
- WebAIM Contrast Checker
- Chrome DevTools（Lighthouse）
- Stark（Figmaプラグイン）

## キーボードアクセシビリティ

### 基本原則

#### 1. すべての機能にキーボードでアクセス可能
マウスでできることは、キーボードでもできる必要がある

#### 2. フォーカスインジケーター
```css
:focus {
  outline: 2px solid primary-500;
  outline-offset: 2px;
}

/* outline: none; は避ける！ */
```

#### 3. タブ順序（Tab Order）
論理的な順序でフォーカスが移動する：
```html
<!-- tabindexの使用 -->
<button tabindex="0">正常</button>      <!-- 自然な順序 -->
<button tabindex="-1">スキップ</button>  <!-- フォーカス不可 -->
<button tabindex="1">避けるべき</button> <!-- 手動順序（非推奨） -->
```

### 主要なキーボード操作

#### 基本ナビゲーション
- **Tab**: 次の要素へ
- **Shift + Tab**: 前の要素へ
- **Enter**: リンク・ボタンの実行
- **Space**: ボタンの実行、チェックボックスのトグル
- **ESC**: ダイアログ・モーダルを閉じる

#### コンポーネント固有

**Dropdown/Menu:**
- **Arrow Up/Down**: 項目間の移動
- **Home/End**: 最初/最後の項目へ
- **Enter/Space**: 選択
- **ESC**: 閉じる

**Tabs:**
- **Arrow Left/Right**: タブ間の移動
- **Home/End**: 最初/最後のタブへ
- **Enter/Space**: タブの選択

**Modal/Dialog:**
- **Tab**: モーダル内でのフォーカス移動（フォーカストラップ）
- **ESC**: モーダルを閉じる

## スクリーンリーダー対応

### セマンティックHTML

#### 正しい要素を使う
❌ 悪い例：
```html
<div onclick="submit()">送信</div>
```

✅ 良い例：
```html
<button type="submit">送信</button>
```

#### ランドマーク要素
```html
<header>   <!-- バナー -->
<nav>      <!-- ナビゲーション -->
<main>     <!-- メインコンテンツ -->
<aside>    <!-- 補足コンテンツ -->
<footer>   <!-- フッター -->
<section>  <!-- セクション -->
<article>  <!-- 独立したコンテンツ -->
```

### ARIA（Accessible Rich Internet Applications）

#### 基本ルール
1. セマンティックHTMLが使える場合は、ARIAを使わない
2. ARIAのroleを変更しない
3. すべてのARIAはキーボードアクセス可能にする

#### よく使うARIA属性

**role属性:**
```html
<div role="button">ボタン</div>
<div role="dialog">ダイアログ</div>
<div role="alert">アラート</div>
<div role="navigation">ナビゲーション</div>
```

**aria-label（要素のラベル）:**
```html
<button aria-label="閉じる">
  <IconX />
</button>
```

**aria-labelledby（別の要素でラベル）:**
```html
<div role="dialog" aria-labelledby="dialog-title">
  <h2 id="dialog-title">確認</h2>
  ...
</div>
```

**aria-describedby（追加の説明）:**
```html
<input
  id="email"
  type="email"
  aria-describedby="email-help"
/>
<span id="email-help">例: user@example.com</span>
```

**aria-hidden（スクリーンリーダーから隠す）:**
```html
<span aria-hidden="true">🎉</span>
<span class="sr-only">お祝い</span>
```

**aria-expanded（展開状態）:**
```html
<button aria-expanded="false" aria-controls="menu">
  メニュー
</button>
<div id="menu">...</div>
```

**aria-current（現在の項目）:**
```html
<nav>
  <a href="/home" aria-current="page">ホーム</a>
  <a href="/about">概要</a>
</nav>
```

**aria-disabled（無効状態）:**
```html
<button aria-disabled="true">送信</button>
```

**aria-invalid（エラー状態）:**
```html
<input
  type="email"
  aria-invalid="true"
  aria-describedby="email-error"
/>
<span id="email-error" role="alert">
  有効なメールアドレスを入力してください
</span>
```

**aria-live（動的コンテンツの通知）:**
```html
<div aria-live="polite">読み込み中...</div>
<div aria-live="assertive" role="alert">エラーが発生しました</div>
```

### スクリーンリーダー専用テキスト

```css
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border-width: 0;
}
```

```html
<button>
  <IconTrash />
  <span class="sr-only">削除</span>
</button>
```

## フォームのアクセシビリティ

### ラベルの関連付け

```html
<!-- 方法1: for属性 -->
<label for="username">ユーザー名</label>
<input id="username" type="text" />

<!-- 方法2: ラップ -->
<label>
  ユーザー名
  <input type="text" />
</label>
```

### 必須フィールド

```html
<label for="email">
  メールアドレス
  <span aria-label="必須">*</span>
</label>
<input
  id="email"
  type="email"
  required
  aria-required="true"
/>
```

### エラーメッセージ

```html
<label for="password">パスワード</label>
<input
  id="password"
  type="password"
  aria-invalid="true"
  aria-describedby="password-error"
/>
<span id="password-error" role="alert">
  パスワードは8文字以上必要です
</span>
```

### フィールドのグループ化

```html
<fieldset>
  <legend>配送方法</legend>
  <label>
    <input type="radio" name="shipping" value="standard" />
    通常配送
  </label>
  <label>
    <input type="radio" name="shipping" value="express" />
    速達
  </label>
</fieldset>
```

## フォーカス管理

### フォーカストラップ（モーダル）

```javascript
// モーダル内の最初と最後のフォーカス可能要素
const firstFocusable = modal.querySelector('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])');
const focusableContent = modal.querySelectorAll('...');
const lastFocusable = focusableContent[focusableContent.length - 1];

// 最後の要素でTabを押したら最初に戻る
lastFocusable.addEventListener('keydown', (e) => {
  if (e.key === 'Tab' && !e.shiftKey) {
    e.preventDefault();
    firstFocusable.focus();
  }
});
```

### スキップリンク

```html
<a href="#main-content" class="skip-link">
  メインコンテンツへスキップ
</a>
```

```css
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: #000;
  color: white;
  padding: 8px;
  text-decoration: none;
  z-index: 100;
}

.skip-link:focus {
  top: 0;
}
```

## タッチターゲット

### 最小サイズ
- **iOS (Apple HIG)**: 44×44pt
- **Android (Material Design)**: 48×48dp
- **WCAG 2.1 AAA**: 44×44px

### スペーシング
隣接するタッチターゲット間: 8px以上

```css
.touch-target {
  min-width: 44px;
  min-height: 44px;
  padding: 12px;
}
```

## 動きとアニメーション

### prefers-reduced-motion

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

### 自動再生
- 動画・音声の自動再生は避ける
- 必要な場合はコントロールを提供

## テスト方法

### 自動テスト
- **axe DevTools**: ブラウザ拡張
- **Lighthouse**: Chrome DevTools
- **Pa11y**: CI/CDに統合可能

### 手動テスト

#### キーボードテスト
1. マウスを使わずにすべての機能を操作
2. フォーカスインジケーターが常に見える
3. タブ順序が論理的

#### スクリーンリーダーテスト
- **macOS**: VoiceOver（Cmd + F5）
- **Windows**: NVDA（無料）、JAWS
- **iOS**: VoiceOver
- **Android**: TalkBack

#### カラーコントラストテスト
- WebAIM Contrast Checker
- Chrome DevTools

#### カラーブラインドネステスト
- Chromaシミュレータ
- Color Oracle

### チェックリスト

#### ページレベル
- [ ] ページタイトルは適切か
- [ ] 見出し構造は論理的か（H1 → H2 → H3）
- [ ] ランドマーク要素は適切に使われているか
- [ ] スキップリンクはあるか

#### コンテンツ
- [ ] すべての画像にalt属性があるか
- [ ] カラーコントラストは十分か
- [ ] テキストサイズは調整可能か
- [ ] 色だけで情報を伝えていないか

#### インタラクション
- [ ] キーボードですべて操作可能か
- [ ] フォーカスインジケーターは見やすいか
- [ ] タブ順序は論理的か
- [ ] タッチターゲットは十分な大きさか

#### フォーム
- [ ] すべての入力にラベルがあるか
- [ ] エラーメッセージは明確か
- [ ] 必須フィールドは識別できるか
- [ ] aria-invalidが適切に使われているか

#### 動的コンテンツ
- [ ] スクリーンリーダーに変更が通知されるか
- [ ] フォーカス管理は適切か
- [ ] モーダルのフォーカストラップは動作するか

## 参考リソース
- **WCAG 2.1**: https://www.w3.org/WAI/WCAG21/quickref/
- **WAI-ARIA**: https://www.w3.org/WAI/ARIA/apg/
- **WebAIM**: https://webaim.org/
- **A11y Project**: https://www.a11yproject.com/
- **Inclusive Components**: https://inclusive-components.design/
