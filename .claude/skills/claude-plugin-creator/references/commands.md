# Slash Commands

## Location

```
my-plugin/
└── commands/
    ├── my-command.md
    └── subdir/
        └── nested-command.md  # Creates namespaced command
```

## Format

```markdown
---
description: Brief command description (required for SlashCommand tool)
allowed-tools: Bash(git:*), Read, Write
argument-hint: [arg1] [arg2]
model: claude-3-5-haiku-20241022
disable-model-invocation: false
---

# Command Instructions

Your prompt here. Use $ARGUMENTS for all args or $1, $2 for specific args.

## Context

- Current status: !`git status`
- File content: @src/file.js
```

## Frontmatter Fields

| Field | Description | Default |
|-------|-------------|---------|
| `description` | Command description | First line |
| `allowed-tools` | Tool whitelist | Inherited |
| `argument-hint` | Expected args hint | None |
| `model` | Specific model | Inherited |
| `disable-model-invocation` | Block SlashCommand tool | false |

## Features

### Arguments

```markdown
Fix issue #$ARGUMENTS
# /fix-issue 123 high → "123 high"

Review PR #$1 with priority $2
# /review 456 high → $1="456", $2="high"
```

### Bash Execution

```markdown
Current branch: !`git branch --show-current`
Recent commits: !`git log --oneline -5`
```

### File References

```markdown
Review @src/utils.js and @src/index.js
```

## Example: Commit Command

```markdown
---
description: Create a git commit with generated message
allowed-tools: Bash(git:*)
---

## Context
- Status: !`git status`
- Diff: !`git diff --staged`

## Task
Create a commit message based on staged changes.
```
