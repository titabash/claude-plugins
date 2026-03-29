# パフォーマンス最適化

スキルの実行速度とコンテキスト効率を最適化するテクニック。

## コンテキストウィンドウ管理

### コンテキスト消費の理解

```
セッション開始時:
├── システムプロンプト: ~2000トークン
├── 全スキルのfrontmatter: ~100トークン × スキル数
└── 会話履歴: 累積

スキル起動時:
├── SKILL.md本文: ~1500-3000トークン
└── 参照ファイル: ~500-1500トークン × 読み込みファイル数

→ 合計: 1セッションで3-4個のreferencesを読むと~10000トークン消費
```

### 最小読み込み原則

**すべてのリファレンスを読まない**。フェーズごとに必要なファイルのみ読み込む。

```markdown
# 悪い例: Phase 2で全リファレンスを読み込み
### Phase 2: リファレンス読み込み
Read references/architecture.md
Read references/schema-design.md
Read references/use-cases.md
Read references/entity-extraction.md
Read references/query-patterns.md
Read references/indexing-strategies.md
Read references/community-detection.md
Read references/chunking-strategies.md

# 良い例: 各フェーズで必要なファイルだけ
### Phase 3: Entity設計
Read references/use-cases.md

### Phase 5: スキーマ生成
Read references/schema-design.md
Read templates/schema-core.sql

### Phase 6: インデックス生成
Read references/indexing-strategies.md
```

### 条件付き読み込み

すべてのケースで必要ないリファレンスは条件付きに。

```markdown
### Phase 3: 追加機能設計

**時系列サポートが必要な場合のみ**:
Read references/time-series.md

**Global Searchが必要な場合のみ**:
Read references/community-detection.md
```

## モデル選択

frontmatterの`model`フィールドでコスト/品質トレードオフを制御。

| モデル | 用途 | コスト | 品質 |
|--------|------|--------|------|
| haiku | 構文チェック、フォーマット、単純変換 | 低 | 基本 |
| sonnet | コード生成、分析、標準タスク | 中 | 高 |
| opus | 設計判断、複雑な推論、アーキテクチャ | 高 | 最高 |

```yaml
# 軽量タスク向け
model: claude-haiku-4-5-20251001

# 標準（デフォルト、指定不要）
# model: claude-sonnet-4-6

# 複雑タスク向け
model: claude-opus-4-6
```

**判断基準**:
- 明確なルールに基づく変換 → haiku
- 判断を含む生成 → sonnet
- 複雑な設計・アーキテクチャ → opus

## 明示的ファイル読み込み

**Claudeはreferences/のファイルを自動読み込みしない**。必ず明示的に指示する。

```markdown
# 良い例: 明示的
### Phase 2: カラーシステム設計
Read [references/color-systems.md](references/color-systems.md) を参照し、
プライマリカラーパレットを設計する。

# 悪い例: 暗黙的
### Phase 2: カラーシステム設計
カラーシステムのベストプラクティスに基づいて設計する。
```

## scripts/の活用

決定的な操作はscripts/に委譲し、コンテキストを節約。

### コンテキストに読み込む場合（references/）

```
Claudeがファイル全文を読む → コンテキスト消費
→ 知識に基づいて判断 → 出力生成
```

### 実行する場合（scripts/）

```
Claudeがスクリプトを実行 → 結果のみ取得
→ コンテキスト消費は最小限
```

**使い分け**:
- バリデーション → scripts/（結果だけあればよい）
- 設計判断 → references/（知識全体が必要）

## SKILL.md行数の最適化

### 行数削減テクニック

1. **テーブル活用**: 箇条書きよりテーブルの方がコンパクト
2. **リファレンスへの委任**: 詳細説明はreferences/へ
3. **冗長な説明の削除**: 「以下に示す」「次に」などの接続詞を削減
4. **例の最小化**: SKILL.md内の例は1-2個に。詳細例はreferences/へ

### 行数チェック

```bash
wc -l SKILL.md
# 目標: 300-400行
# 上限: 500行
```

## /compact の活用

長いセッションでレスポンスが遅くなった場合:

1. `/compact` コマンドで会話を圧縮
2. 重要なコンテキストは保持される
3. 処理トークン数が削減され、速度が回復

**スキル設計への影響**: compactされても失われない情報をSKILL.mdに書く。
一時的な情報（中間結果等）はファイルに書き出しておく。

## パフォーマンスチェックリスト

- [ ] SKILL.mdが500行以内か
- [ ] リファレンスの読み込みは各フェーズで必要最小限か
- [ ] 条件付き読み込みが適切に使われているか
- [ ] scripts/で代替できる処理がreferences/に置かれていないか
- [ ] モデル選択がタスクの複雑さに適しているか
- [ ] 中間結果をファイルに書き出しているか（compact対策）
