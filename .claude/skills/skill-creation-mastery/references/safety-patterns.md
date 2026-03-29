# 安全性パターン

スキルが意図しない副作用を起こさないようにする設計パターン。

## 3つの安全メカニズム

| メカニズム | 用途 | 設定 |
|-----------|------|------|
| `allowed-tools` | 使用可能ツールの制限 | frontmatter |
| `disable-model-invocation` | 自動起動の禁止 | frontmatter |
| scripts抽象化 | 危険コマンドのカプセル化 | scripts/ |

## 1. allowed-tools（ツール制限）

### 最小権限の原則

スキルに必要最小限のツールのみを許可。

```yaml
# 分析スキル: 読み取りのみ
allowed-tools: Read, Grep, Glob

# 生成スキル: 読み書き + ディレクトリ作成
allowed-tools: Read, Write, Bash(mkdir:*), AskUserQuestion

# デプロイスキル: git操作のみ
allowed-tools: Bash(git:*), Read
```

### パターン構文

```yaml
# 特定コマンドプレフィックス
allowed-tools: Bash(git:*)         # git で始まるコマンドのみ
allowed-tools: Bash(npm run:*)     # npm run で始まるコマンドのみ
allowed-tools: Bash(bun test:*)    # bun test で始まるコマンドのみ

# 複数パターン
allowed-tools: Bash(git:*), Bash(npm run test:*), Read, Write

# MCPサーバー制限
allowed-tools: mcp__myserver__*, Read
```

### よくあるallowed-toolsプリセット

| 用途 | allowed-tools |
|------|---------------|
| 読み取り専用分析 | `Read, Grep, Glob` |
| コード生成 | `Read, Write, Edit, Glob, Grep` |
| テスト実行 | `Read, Grep, Glob, Bash(npm run test:*)` |
| Git操作 | `Read, Bash(git:*)` |
| フルアクセス | （未指定 = 全ツール） |

## 2. disable-model-invocation（自動起動禁止）

### 使用すべきケース

**副作用が大きいスキル**に設定:

```yaml
---
name: deploying
description: 本番環境へのデプロイを実行。
disable-model-invocation: true
---
```

Claudeが自動的にこのスキルを選択することはない。
ユーザーが明示的に `/deploying` と入力した場合のみ起動。

### 具体例

| スキル | disable-model-invocation | 理由 |
|--------|--------------------------|------|
| コード分析 | false（デフォルト） | 副作用なし |
| ファイル生成 | false | ユーザーが期待する動作 |
| git commit/push | **true** | 外部に影響 |
| デプロイ | **true** | 本番環境に影響 |
| メール送信 | **true** | 外部に送信 |
| DB マイグレーション | **true** | データに影響 |

## 3. scripts抽象化

複雑または危険なシェルコマンドをスクリプトにカプセル化。

### 問題

```yaml
# allowed-toolsでは制御が難しい例
allowed-tools: Bash(curl:*)  # curlの引数は何でも渡せてしまう
```

### 解決策

```bash
# scripts/deploy.sh
#!/bin/bash
set -euo pipefail

TARGET=${1:-staging}
if [[ "$TARGET" != "staging" && "$TARGET" != "production" ]]; then
    echo "Error: Invalid target. Use 'staging' or 'production'" >&2
    exit 2
fi

# 安全なデプロイ処理
...
```

```yaml
# SKILL.md frontmatter
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/deploy.sh:*)
```

→ 任意のコマンドではなく、検証済みスクリプトのみ実行可能。

## 入力バリデーション

### ユーザー入力の検証

```markdown
### Phase 1: 入力検証
$ARGUMENTSを解析:
- プロジェクト名: 英数字とハイフンのみ（パスインジェクション防止）
- ファイルパス: プロジェクトディレクトリ外への書き込み禁止
- URL: httpまたはhttpsスキームのみ
```

### 出力先の制御

```markdown
## Output Location
出力先: {PROJECT_ROOT}/generated/
（← .claude/ や / への書き込みを防止）
```

## ファイル上書き防止

```markdown
### Phase 1: 既存チェック
出力先ディレクトリの存在を確認:
ls -la {OUTPUT_DIR}/

**存在する場合**:
AskUserQuestion: 「既存のファイルを上書きしますか？」
- 上書き
- 別名で保存
- キャンセル
```

## 安全性チェックリスト

- [ ] allowed-toolsが最小権限に設定されているか
- [ ] 副作用スキルに `disable-model-invocation: true` が設定されているか
- [ ] 危険なコマンドがscripts/にカプセル化されているか
- [ ] ユーザー入力がバリデーションされているか
- [ ] 出力先パスが制御されているか
- [ ] 既存ファイルの上書き前に確認があるか
- [ ] 外部API呼び出しの前にユーザー確認があるか
