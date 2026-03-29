# Progressive Disclosure（段階的情報開示）

スキルの情報を3段階で開示し、コンテキストウィンドウを効率的に使用するパターン。

## 3段階モデル

```
┌─────────────────────────────────────────┐
│ Level 1: Frontmatter                     │
│ (name + description)                     │
│ → セッション開始時に全スキル読み込み       │
│ → ~100トークン                           │
├─────────────────────────────────────────┤
│ Level 2: SKILL.md 本文                   │
│ (手順、フロー、要点)                      │
│ → スキル起動時に読み込み                  │
│ → 500行以内（~1500-2000ワード）          │
├─────────────────────────────────────────┤
│ Level 3: references/, scripts/, assets/  │
│ (詳細知識、テンプレート、スクリプト)       │
│ → 実行中に明示的Readで読み込み            │
│ → 各ファイル80-200行                     │
└─────────────────────────────────────────┘
```

## 各レベルの役割

### Level 1: Frontmatter（入口）

**目的**: Claudeがスキルを発見・選択するための最小限の情報

```yaml
---
name: my-skill
description: [WHAT + WHEN]
---
```

- セッション開始時に**全スキル**のfrontmatterが読み込まれる
- description最適化が極めて重要（→ description-optimization.md）
- 100トークン程度に収める

### Level 2: SKILL.md本文（手順書）

**目的**: スキル起動後、Claudeが実行手順を理解するための情報

書くべきもの:
- 実行フロー（Phase 1, 2, 3...）
- 条件分岐ロジック
- リファレンスファイルへの明示的リンク
- 出力先パスとフォーマット
- 要点の簡潔なサマリー

**書かないもの**（Level 3へ移動）:
- 詳細なドメイン知識
- 具体例の網羅
- APIリファレンス
- テンプレート本文

### Level 3: references/（百科事典）

**目的**: 実行中に必要な詳細情報をオンデマンドで提供

```
references/
├── domain-knowledge.md      # ドメイン固有の知識
├── api-reference.md          # API仕様
├── patterns-catalog.md       # パターン集
└── examples.md               # 詳細な具体例
```

**重要**: Level 3のファイルは自動読み込みされない。SKILL.md内で明示的に指示する:

```markdown
### Phase 2: スキーマ設計
参照: Read [references/schema-design.md](references/schema-design.md) を読んで設計パターンを確認。
```

## 行数バジェット

| コンポーネント | 推奨行数 | 上限 |
|--------------|---------|------|
| SKILL.md全体 | 300-400行 | 500行 |
| 概要セクション | 15-25行 | 30行 |
| 実行フロー | 80-120行 | 150行 |
| 要点サマリー | 40-60行 | 80行 |
| リファレンスリスト | 20-30行 | 40行 |
| 各referenceファイル | 80-150行 | 200行 |

### 行数超過時の対処

SKILL.mdが500行を超える場合:

1. **詳細な例をreferences/に移動**: 「良い例/悪い例」のセクションが長い場合
2. **パターン集をreferences/に移動**: 複数のパターンを列挙するセクション
3. **テーブルの詳細行を削減**: 要約テーブルだけ残し、詳細はreferences/
4. **セクションの統合**: 重複する説明を統合

## 実例: GraphRAG PostgreSQLスキル

```
SKILL.md (175行)
├── Overview: 30行
├── Execution Flow (10 phases): 100行
├── Reference Files list: 20行
└── Template Files list: 15行

references/ (8ファイル, 合計~1200行)
├── architecture.md: ~150行
├── schema-design.md: ~180行
├── use-cases.md: ~200行
├── entity-extraction.md: ~150行
├── query-patterns.md: ~150行
├── indexing-strategies.md: ~120行
├── community-detection.md: ~130行
└── chunking-strategies.md: ~120行
```

SKILL.mdは175行で全体の手順を示し、8つのリファレンスファイルに~1200行の詳細知識を格納。
合計~1375行の情報を、実行時には必要な部分だけ読み込む。

## 設計判断フロー

```
この情報はスキル発見に必要か？
  → Yes → Level 1 (frontmatter description)
  → No ↓

この情報は実行手順の理解に必要か？
  → Yes → Level 2 (SKILL.md本文)
  → No ↓

この情報は特定フェーズの実行に必要か？
  → Yes → Level 3 (references/)
  → No → 不要。含めない。
```

## 明示的読み込みパターン

### 良い例（明示的）

```markdown
### Phase 2: カラーシステム設計
[references/color-systems.md](references/color-systems.md) を読み、以下を決定:
- プライマリカラーパレット（50-900スケール）
- セマンティックカラー
- コントラスト比（WCAG準拠）
```

### 悪い例（暗黙的）

```markdown
### Phase 2: カラーシステム設計
カラーシステムのベストプラクティスに基づいて設計する。
（← Claudeはどのファイルを読むべきか分からない）
```

## コンテキストウィンドウへの影響

- Level 1のみ: ~100トークン × スキル数
- Level 1 + 2: ~2000-3000トークン追加
- Level 1 + 2 + Level 3（1ファイル）: ~1000-2000トークン追加

**目安**: 3-4個のreferencesを同時に読み込むと、~8000-10000トークンを消費。
セッションが長くなる場合は `/compact` を活用。
