# Frontmatter全フィールド詳解

SKILL.mdおよびコマンド(.md)のYAML frontmatterで使用可能な全フィールド。

## SKILL.md Frontmatter

### 必須フィールド

#### `name`

スキルの識別子。手動呼び出し時の `/name` コマンドにもなる。

```yaml
name: my-skill-name
```

| 制約 | 値 |
|------|-----|
| 文字種 | 小文字英数字 + ハイフン |
| 最大長 | 64文字 |
| 命名規則 | kebab-case |
| 推奨 | 動名詞形（-ing） |

**例**:
```yaml
name: code-reviewing        # 推奨（動名詞）
name: code-reviewer          # 許容
name: CodeReviewer           # NG（大文字）
name: code_reviewer          # NG（アンダースコア）
```

#### `description`

スキルの説明。Claudeがスキル選択に使用する最重要フィールド。

```yaml
description: [WHAT + WHEN、最大1024文字]
```

| 制約 | 値 |
|------|-----|
| 最大長 | 1024文字 |
| 構造 | WHAT（機能）+ WHEN（トリガー条件） |
| 言語 | 日英バイリンガル推奨 |

詳細 → [description-optimization.md](description-optimization.md)

### オプションフィールド

#### `allowed-tools`

スキル起動中にClaudeが使用できるツールを制限。

```yaml
allowed-tools: Read, Grep, Glob
```

| 特性 | 説明 |
|------|------|
| 大文字小文字 | **区別あり**（case-sensitive） |
| 未指定時 | 全ツール利用可能 |
| 形式 | カンマ区切りリスト |

**ツール名一覧**:

| ツール名 | 機能 |
|----------|------|
| `Read` | ファイル読み取り |
| `Write` | ファイル書き込み |
| `Edit` | ファイル編集 |
| `Glob` | ファイルパターン検索 |
| `Grep` | コンテンツ検索 |
| `Bash` | シェルコマンド実行 |
| `Agent` | サブエージェント起動 |
| `WebFetch` | URL取得 |
| `WebSearch` | Web検索 |
| `AskUserQuestion` | ユーザーへの質問 |

**パターン構文**:

```yaml
# 特定コマンドのみ許可
allowed-tools: Bash(git:*), Read, Write

# gitコマンドのみ
allowed-tools: Bash(git:*)

# 読み取り専用
allowed-tools: Read, Grep, Glob

# MCP特定サーバーのみ
allowed-tools: mcp__myserver__*

# 複数パターン
allowed-tools: Bash(bun run test:*), Bash(bun run lint:*), Read, Write
```

**注意**: `allowed-tools`はClaude Code CLIでのみサポート。SDK経由の場合は`allowedTools`オプションで制御。

#### `disable-model-invocation`

`true`に設定すると、ユーザーが明示的に`/name`で呼び出した場合のみ起動。
Claudeが自動的にスキルを選択して起動することを禁止する。

```yaml
disable-model-invocation: true
```

**使用すべきケース**:
- ファイルの大量書き込みを行うスキル
- 外部APIに送信するスキル
- git commit/pushを行うスキル
- デプロイを実行するスキル
- その他、副作用が大きいスキル

#### `user-invocable`

`false`に設定すると、`/name`コマンドでの手動呼び出しが不可。
バックグラウンド知識スキル（Claudeが参照するが、ユーザーが直接呼び出す必要のないスキル）向け。

```yaml
user-invocable: false
```

#### `model`

スキル起動時に使用するモデルを指定。

```yaml
model: claude-sonnet-4-6
```

**使い分け**:
- デフォルト（未指定）: 現在のセッションモデル
- `claude-haiku-4-5-20251001`: 軽量タスク（構文チェック、フォーマット）
- `claude-sonnet-4-6`: 標準タスク（コード生成、分析）
- `claude-opus-4-6`: 複雑タスク（設計、アーキテクチャ）

## コマンド(.md) Frontmatter

コマンドはスキルと同じフィールドに加え、追加フィールドを持つ:

#### `argument-hint`

コマンドの引数ヒント。`/command` 入力時に表示される。

```yaml
argument-hint: <project-description>
argument-hint: [URL(optional)]
argument-hint: [arg1] [arg2]
```

## Frontmatter記述例

### 読み取り専用分析スキル

```yaml
---
name: code-analyzing
description: コードの品質、セキュリティ、パフォーマンスを分析。Use when user asks for code review, security audit, or performance analysis.
allowed-tools: Read, Grep, Glob
---
```

### ファイル生成スキル

```yaml
---
name: schema-generating
description: データベーススキーマを自動生成。Use when user wants to create database schema, migrations, or table definitions.
allowed-tools: Read, Write, Bash(mkdir:*), AskUserQuestion
---
```

### バックグラウンド知識スキル

```yaml
---
name: project-conventions
description: プロジェクトのコーディング規約。Claudeがコードを書く際に自動参照。Use when writing or reviewing code in this project.
user-invocable: false
---
```

### 副作用スキル（手動起動のみ）

```yaml
---
name: deploying
description: ステージング/本番環境へのデプロイを実行。Use when user explicitly requests deployment.
allowed-tools: Bash(git:*), Bash(deploy:*), Read
disable-model-invocation: true
---
```

## よくある間違い

| 間違い | 正しい書き方 |
|--------|-------------|
| `Allowed-Tools: read` | `allowed-tools: Read`（小文字キー、大文字ツール名） |
| `name: My Skill` | `name: my-skill`（kebab-case） |
| description内の改行 | 1行で記述（YAML制約） |
| allowed-toolsの空白なし | `Read, Write`（カンマ+スペース） |
