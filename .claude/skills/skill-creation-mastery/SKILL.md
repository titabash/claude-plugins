---
name: skill-creation-mastery
description: Claude Code Skillの品質ガイドライン。SKILL.md生成時のdescription最適化、Progressive Disclosure、マルチフェ��ズ設計、allowed-tools設定の品質基準。Claudeがスキルを生成・編集する際に自動参照。Use when generating or editing SKILL.md files, writing skill descriptions, or structuring skill directories.
user-invocable: false
---

# Skill Creation Quality Guidelines

Claudeがスキルを生成・編集する際に従うべき品質基準。
`claude-plugin-creator`と連携し、生成されるスキルの品質を担保する。

---

## 必須チェックリスト

スキル���成時に以下をすべて満たすこと:

- [ ] SKILL.mdが**500行以内**
- [ ] descriptionが**WHAT+WHEN**フォーミュラに従っている
- [ ] descriptionが**1024文字以内**
- [ ] descriptionに**日英��イリンガル**のトリガーキーワードがある
- [ ] `name`が**kebab-case**、最大64文字
- [ ] 知識(Context)が**references/**に分離されている（SKILL.mdは手順のみ）
- [ ] references/への読み込み指示が**明示的**（「必要に応じて参照」はNG）
- [ ] 副作用スキルに`disable-model-invocation: true`が設定されている
- [ ] `allowed-tools`が**最小権限**になっている

---

## Description設計（WHAT + WHEN フォーミュラ）

```yaml
description: "[WHAT: 何をするか]。[WHEN: いつ使うか]。Use when [English triggers]."
```

**良い例**:
```yaml
description: PostgreSQL + pgvector + PGroonga で GraphRAG を構築。自然言語でプロジェクトを説明すると、最適なEntity/Edge型、スキーマ、クエリパターンを設計・生成。Use when the user mentions "GraphRAG", "knowledge graph", or wants to build RAG with relationships.
```

**悪い��**:
```yaml
description: ドキュメントを処理する
```

**ポイント**:
- WHATは具体的な機能を列挙（動詞+対象）
- WHENは起動条件とキーワードを明記
- 末尾に英語トリガー文を追加（バイリンガル対応）
- 200-400文字が最適レンジ

詳細 → [references/description-optimization.md](references/description-optimization.md)

---

## Progressive Disclosure（3段階開示）

| Level | 内容 | タイミング | サ��ズ |
|-------|------|-----------|--------|
| 1 | name + description | セッション開始時（全スキル） | ~100トークン |
| 2 | SKILL.md本文 | スキル起動時 | **500行以内** |
| 3 | references/, scripts/ | 実行中に**明示的Read** | 各80-200行 |

**SKILL.md = 手順書（Process）**:
- 実行フロー（Phase 1, 2, 3...）
- 条件分岐
- ツール指示、出力先パス

**references/ = 百科事典（Context）**:
- ドメイン知識、パターン集
- 詳細な例、ルール
- API仕様、スキーマ

**重要**: references/は自動読み込みされない。各フェーズで明示的にReadを指示:
```markdown
### Phase 2: カラー設計
Read [references/color-systems.md](references/color-systems.md) を参照し、パレットを設計。
```

詳�� → [references/progressive-disclosure.md](references/progressive-disclosure.md), [references/process-context-separation.md](references/process-context-separation.md)

---

## 実行フロー設計（標準パターン）

生成するスキルのフローは以下の標準パターンに沿って設計:

```
Phase 1: 要件分析 (Analyze)     ← ユーザー入力の解析、AskUserQuestion
Phase 2: リファレンス読み込み (Read) ← 必要なreferences/のみ読む
Phase 3: 設計 (Design)          ← 知識+要件を組み合わせて設計
Phase 4: ユー��ー確認 (Confirm)  ← 提案→確認パターン（選択肢を提示）
Phase 5: 生成/実行 (Generate)   ← テンプレート読み込み→カスタマイズ→Write
Phase 6: 完了レポート (Report)   ← ファイル一覧、次��ステップ
```

**フェーズ設計ルール**:
- 各フェーズは単一責任
- リファレンス読み込みは使用直前（先読みしない）
- 生成物が多い場合はGenerateフェーズを分割
- 条件分岐は明示的に記述

**フェーズ数の目安**:
- シンプル: 3-4フェーズ
- 標準: 5-6フェーズ
- 複雑: 7-10フェーズ（10超えは分割を検討）

詳細 → [references/execution-flow-patterns.md](references/execution-flow-patterns.md)

---

## Frontmatter設定

### 必須フィールド

| フィールド | 制約 |
|-----------|------|
| `name` | kebab-case、最大64文字 |
| `description` | WHAT+WHEN、最大1024文字 |

### オプション（適切に設定）

| フィールド | 用途 | 設定すべきケース |
|-----------|------|----------------|
| `allowed-tools` | ツール制限（case-sensitive） | 読み取り専用スキル、限定操作スキル |
| `disable-model-invocation` | 自動起動禁止 | git push、デプロイ、外部API送信 |
| `user-invocable: false` | 手動呼出し不可 | バックグラウンド知識スキル |
| `model` | モデル指定 | 軽量/高品質タスクの使い分け |

**allowed-toolsプリセット**:
```yaml
# 読み取り専用
allowed-tools: Read, Grep, Glob

# コード生成
allowed-tools: Read, Write, Edit, Glob, Grep

# Git操作限定
allowed-tools: Read, Bash(git:*)

# 特定コマンド限定
allowed-tools: Bash(bun run test:*), Read, Write
```

詳細 → [references/frontmatter-advanced.md](references/frontmatter-advanced.md)

---

## ユーザー対話設計

AskUserQuestionを使う場合のルール:

1. **構造化質問**: 自由入力より選択肢を提示
2. **提案→確認**: ゼロから聞くのではなく、スキルが提案してユーザーが承認
3. **必須→任意**: 重要項目を先に
4. **確認は生成前**: 手戻りコスト最小化

詳細 → [references/user-interaction-patterns.md](references/user-interaction-patterns.md)

---

## ディレクトリ構造

```
my-skill/
├── SKILL.md           # 必須: 手順(Process)
��── references/        # 任意: 知識(Context) - Readでコンテキストに読み込む
├── templates/         # 任意: 生成用雛形 - Read→カスタマイズ→Write
├── scripts/           # 任意: 実行コード - Bashで実行（コンテキスト外）
└── assets/            # 任意: 静的ファイル - コピー用（コンテキスト外）
```

**サイズガイドライン**:
| コンポーネント | 推奨行数 |
|--------------|---------|
| SKILL.md | 300-400行（上限500） |
| 各referenceファイル | 80-200行 |
| 各templateファイル | 30-200行 |

詳細 → [references/reference-architecture.md](references/reference-architecture.md)

---

## Anti-Patterns（回避すべきパターン）

| パターン | 問題 | 対策 |
|---------|------|------|
| モノリシックSKILL.md | 500行超、知識を直接埋め込み | references/に分離 |
| 曖昧description | 「便利なツール」等、WHAT/WHENなし | WHAT+WHENフォーミュラ |
| 暗黙リファレンス読み込み | 「必要に応じて参照」 | 明示的Readリンク |
| 自由入力のみ質問 | 「何を作りたいですか？」 | 選択肢付き構造化質問 |
| ツール制限なし | 副作用スキルが全ツール使用可 | allowed-tools + disable-model-invocation |
| 完了レポート省略 | 何が生成されたか不明 | 最終フェーズで一覧と次のステップ |

---

## Reference Files

各テクニックの詳細（必要時にReadで読み込む）:

- [references/description-optimization.md](references/description-optimization.md) - WHAT+WHENフォーミュラ、トリガーキーワード戦略
- [references/progressive-disclosure.md](references/progressive-disclosure.md) - 3段階開示モデル、行数バジェット
- [references/process-context-separation.md](references/process-context-separation.md) - Process/Context分離判断
- [references/execution-flow-patterns.md](references/execution-flow-patterns.md) - 標準6フェーズパターン
- [references/frontmatter-advanced.md](references/frontmatter-advanced.md) - 全フィールド詳解
- [references/reference-architecture.md](references/reference-architecture.md) - ディレ���トリ構造設計
- [references/user-interaction-patterns.md](references/user-interaction-patterns.md) - AskUserQuestion設計
- [references/skill-composition.md](references/skill-composition.md) - メタスキル、チェイニング
- [references/testing-evaluation.md](references/testing-evaluation.md) - テスト・評価手法
- [references/performance-optimization.md](references/performance-optimization.md) - コンテキスト管理
- [references/safety-patterns.md](references/safety-patterns.md) - 安全設計パターン

## Template Files

- [templates/skill-md-template.md](templates/skill-md-template.md) - SKILL.md生成テンプレート
- [templates/reference-doc-template.md](templates/reference-doc-template.md) - リファレンス文書テンプレート
