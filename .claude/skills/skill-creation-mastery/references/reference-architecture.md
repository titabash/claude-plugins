# Reference Architecture（ディレクトリ構造設計）

スキルのサブディレクトリ（references/, templates/, scripts/, assets/）の役割と使い分け。

## ディレクトリ構造

```
my-skill/
├── SKILL.md           # 必須: 手順とフロー
├── references/        # 任意: 知識ドキュメント（コンテキストに読み込まれる）
├── templates/         # 任意: 生成用テンプレート（読み込み→カスタマイズ→出力）
├── scripts/           # 任意: 実行可能コード（実行される、コンテキストに読み込まない）
└── assets/            # 任意: 静的ファイル（出力に使用、コンテキストに読み込まない）
```

## 各ディレクトリの役割

### references/（知識ドキュメント）

**用途**: Claudeが判断に必要な背景知識

**コンテキスト**: Readで読み込まれる（コンテキストウィンドウを消費）

**配置するもの**:
- ドメイン知識（設計パターン、ベストプラクティス）
- API仕様・スキーマ定義
- パターンカタログ
- 具体例の集積
- ルール・制約の詳細

**ファイル命名**:
```
references/
├── architecture.md          # 全体設計
├── schema-design.md         # スキーマ設計パターン
├── use-cases.md             # ユースケース別パターン
├── color-systems.md         # カラーシステム理論
├── accessibility.md         # アクセシビリティ基準
└── query-patterns.md        # クエリパターン集
```

**サイズガイドライン**: 各ファイル80-200行

### templates/（生成用テンプレート）

**用途**: ファイル生成のベース。Readで読み込み、カスタマイズしてWriteで出力。

**コンテキスト**: Readで読み込まれる

**配置するもの**:
- SQLテンプレート（`{{VARIABLE}}`プレースホルダー付き）
- コード雛形
- Markdownテンプレート
- JSON設定テンプレート

**プレースホルダー構文**:
```sql
-- templates/schema-core.sql
CREATE TABLE entities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    embedding vector({{EMBEDDING_DIM}}),
    ...
);
```

```markdown
<!-- templates/skill-template.md -->
---
name: {{SKILL_NAME}}
description: {{DESCRIPTION}}
---

# {{SKILL_TITLE}}

## Overview
{{OVERVIEW}}

## Execution Flow
{{EXECUTION_FLOW}}
```

**ファイル命名**:
```
templates/
├── schema-core.sql          # SQLスキーマ雛形
├── skill-template.md        # SKILL.md雛形
├── component-template.md    # コンポーネント雛形
└── design-tokens.json       # デザイントークン雛形
```

### scripts/（実行可能コード）

**用途**: 決定的な操作をコードで実行。コンテキストに読み込まずにBashで実行。

**コンテキスト**: 読み込まれない（実行のみ）

**配置するもの**:
- バリデーションスクリプト
- ファイル変換スクリプト
- テストランナー
- ビルドスクリプト

```bash
# scripts/validate.sh
#!/bin/bash
# プラグイン構造のバリデーション
PLUGIN_DIR=$1
...
```

**SKILL.mdからの参照**:
```markdown
### Phase 6: バリデーション
Bash: `${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh ${OUTPUT_DIR}`
```

### assets/（静的ファイル）

**用途**: 出力にコピーされるが、コンテキストに読み込まない静的ファイル。

**コンテキスト**: 読み込まれない

**配置するもの**:
- 画像ファイル
- フォントファイル
- アイコン
- サンプルデータ

## 使い分け判断フロー

```
この情報はClaudeの判断に必要か？
  ├→ Yes: コンテキストに読み込む必要がある
  │   ├→ そのまま参照する → references/
  │   └→ カスタマイズして出力する → templates/
  └→ No: コンテキスト外で使用
      ├→ 実行する → scripts/
      └→ コピーする → assets/
```

## サイズガイドライン

| ディレクトリ | 1ファイルの行数 | ファイル数の目安 |
|-------------|---------------|----------------|
| SKILL.md | 300-500行 | 1（必須） |
| references/ | 80-200行 | 3-10 |
| templates/ | 30-200行 | 1-5 |
| scripts/ | 20-100行 | 0-3 |
| assets/ | - | 必要に応じて |

## ファイル分割の判断基準

### references/のファイル分割

1つのリファレンスファイルが200行を超える場合、分割を検討:

```
# 分割前
references/design-system.md (400行)

# 分割後
references/color-systems.md (120行)
references/typography-scales.md (100行)
references/spacing-systems.md (80行)
references/component-patterns.md (100行)
```

**分割の基準**:
- 独立して参照可能か（Phase Aでは色だけ、Phase Bではタイポグラフィだけ読みたい）
- 1つのトピックが80行以上あるか
- 条件分岐で一部しか読まないケースがあるか

### references/の統合

逆に、20行程度の小さなファイルが多数ある場合は統合を検討:

```
# 統合前（細かすぎる）
references/button.md (15行)
references/input.md (20行)
references/card.md (18行)

# 統合後
references/component-patterns.md (53行)
```

## 実例

### GraphRAG PostgreSQL

```
graphrag/
├── SKILL.md (175行)
├── references/ (8ファイル, ~1200行)
│   ├── architecture.md
│   ├── schema-design.md
│   ├── use-cases.md
│   ├── entity-extraction.md
│   ├── query-patterns.md
│   ├── indexing-strategies.md
│   ├── community-detection.md
│   └── chunking-strategies.md
└── templates/ (6ファイル, ~400行)
    ├── schema-core.sql
    ├── schema-extensions.sql
    ├── indexes.sql
    ├── query-local.sql
    ├── query-global.sql
    └── query-hybrid.sql
```

references/は知識（設計パターン、戦略）、templates/は生成物の雛形（SQL）と明確に分離。

### UI Design Guideline

```
ui-design-guideline/
├── SKILL.md (132行)
├── references/ (6ファイル, ~900行)
│   ├── color-systems.md
│   ├── typography-scales.md
│   ├── spacing-systems.md
│   ├── component-patterns.md
│   ├── accessibility.md
│   └── website-analysis.md
└── templates/ (4ファイル, ~300行)
    ├── skill-template.md
    ├── guideline-template.md
    ├── component-template.md
    └── design-tokens.json
```

references/は設計理論、templates/は出力物の雛形と分離。
