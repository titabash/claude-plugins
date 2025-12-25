# Hooks

## Location

```
my-plugin/
└── hooks/
    └── hooks.json
```

## Format

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "ToolPattern",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/handler.sh"
          }
        ]
      }
    ]
  }
}
```

## Event Types

| Event | Trigger | Matcher |
|-------|---------|---------|
| `PreToolUse` | Before tool execution | Tool name |
| `PostToolUse` | After tool success | Tool name |
| `UserPromptSubmit` | User sends prompt | - |
| `Notification` | System notification | - |
| `Stop` | Main agent completes | - |
| `SubagentStop` | Subagent completes | - |
| `SessionStart` | Session begins | - |
| `SessionEnd` | Session ends | - |
| `PreCompact` | Before compact | `manual`/`auto` |

## Matcher Patterns

```json
"matcher": "Write"           // Exact match
"matcher": "Edit|Write"      // Regex OR
"matcher": "Bash.*"          // Regex wildcard
"matcher": "*"               // All tools
"matcher": "mcp__server__.*" // MCP tools
```

## Hook Output

### Simple: Exit Codes

```
0: Success (continue)
2: Block with error (stderr shown to Claude)
Other: Non-blocking error
```

### Advanced: JSON Output

```json
{
  "continue": true,
  "stopReason": "string",
  "suppressOutput": false,
  "systemMessage": "Feedback to Claude"
}
```

## Environment Variables

- `${CLAUDE_PLUGIN_ROOT}`: Plugin directory path
- Input passed via stdin as JSON

## Example: Lint on Write

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/lint.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

## Prompt-Based Hooks

For Stop/SubagentStop only:

```json
{
  "type": "prompt",
  "prompt": "Evaluate if task is complete: $ARGUMENTS",
  "timeout": 30
}
```
