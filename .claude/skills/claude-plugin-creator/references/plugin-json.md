# plugin.json Reference

## Location

```
my-plugin/
└── .claude-plugin/
    └── plugin.json
```

## Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Unique ID (kebab-case) |

## Metadata Fields

| Field | Type | Description |
|-------|------|-------------|
| `version` | string | Semantic version (e.g., "1.0.0") |
| `description` | string | Brief explanation |
| `author` | object | `{ name, email?, url? }` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | License (e.g., "MIT") |
| `keywords` | array | Discovery tags |

## Component Path Fields

| Field | Type | Default |
|-------|------|---------|
| `commands` | string\|array | `commands/` |
| `agents` | string\|array | `agents/` |
| `skills` | string\|array | `skills/` |
| `hooks` | string\|object | `hooks/hooks.json` |
| `mcpServers` | string\|object | `.mcp.json` |
| `lspServers` | string\|object | `.lsp.json` |

## Minimal Example

```json
{
  "name": "my-plugin",
  "description": "My first plugin",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  }
}
```

## Full Example

```json
{
  "name": "enterprise-tools",
  "version": "2.1.0",
  "description": "Enterprise development tools",
  "author": {
    "name": "Team Name",
    "email": "team@example.com",
    "url": "https://github.com/team"
  },
  "homepage": "https://docs.example.com/plugin",
  "repository": "https://github.com/team/plugin",
  "license": "MIT",
  "keywords": ["enterprise", "tools"],
  "commands": ["./custom/commands/"],
  "skills": "./custom/skills/",
  "hooks": "./config/hooks.json",
  "mcpServers": "./mcp-config.json"
}
```

## Notes

- Custom paths supplement defaults (don't replace)
- Paths must be relative to plugin root (`./`)
- Multiple paths can be arrays
