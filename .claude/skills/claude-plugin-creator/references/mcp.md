# MCP Servers

## Location

```
my-plugin/
└── .mcp.json
```

## Format

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "@some/mcp-server"],
      "env": {
        "API_KEY": "${API_KEY}"
      }
    }
  }
}
```

## Transport Types

### Stdio (Local)

```json
{
  "mcpServers": {
    "local-server": {
      "command": "python",
      "args": ["server.py"],
      "env": {}
    }
  }
}
```

### HTTP

```json
{
  "mcpServers": {
    "api-server": {
      "type": "http",
      "url": "https://api.example.com/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    }
  }
}
```

### SSE (Deprecated)

```json
{
  "mcpServers": {
    "sse-server": {
      "type": "sse",
      "url": "https://api.example.com/sse"
    }
  }
}
```

## Environment Variables

Supported syntax in `.mcp.json`:

```
${VAR}           # Required variable
${VAR:-default}  # With default value
```

Expandable in:
- `command`, `args`, `env`
- `url`, `headers`

## Example: GitHub MCP

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

## Example: Database MCP

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "${DATABASE_URL:-postgresql://localhost/mydb}"
      }
    }
  }
}
```

## Plugin Environment

Use `${CLAUDE_PLUGIN_ROOT}` for plugin-relative paths:

```json
{
  "mcpServers": {
    "custom": {
      "command": "${CLAUDE_PLUGIN_ROOT}/scripts/mcp-server.py",
      "args": []
    }
  }
}
```
