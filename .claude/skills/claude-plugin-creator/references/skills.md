# Agent Skills

## Location

```
my-plugin/
└── skills/
    └── my-skill/
        ├── SKILL.md           # Required
        ├── references/        # Optional: Documentation
        ├── scripts/           # Optional: Executable code
        └── assets/            # Optional: Templates, images
```

## SKILL.md Format

```markdown
---
name: my-skill-name
description: What it does and WHEN to use it. Include trigger scenarios.
allowed-tools: Read, Grep, Glob
---

# Skill Name

## Overview
Brief explanation of what this skill enables.

## Instructions
Step-by-step guidance for using this skill.

## Examples
Concrete examples with realistic user requests.
```

## Frontmatter Fields

| Field | Requirements |
|-------|--------------|
| `name` | Lowercase, hyphens, max 64 chars |
| `description` | Max 1024 chars. Include WHAT and WHEN |
| `allowed-tools` | Optional: Restrict tool access |

## Description Best Practices

**Too vague:**
```yaml
description: Helps with documents
```

**Specific:**
```yaml
description: Extract text from PDF files, fill forms, merge documents. Use when working with PDF files or when user mentions PDFs, forms, or document extraction.
```

## Resource Directories

### references/
Documentation loaded into context as needed.
- API references, schemas, detailed guides
- Keep SKILL.md lean, reference details here

### scripts/
Executable code for deterministic operations.
- Python/Bash scripts for automation
- Can be executed without loading into context

### assets/
Files used in output (not loaded into context).
- Templates, images, fonts, boilerplate

## Example: Code Review Skill

```markdown
---
name: code-reviewer
description: Review code for security, performance, and best practices. Use when user asks for code review, security audit, or performance analysis.
allowed-tools: Read, Grep, Glob
---

# Code Reviewer

## Workflow
1. Identify files to review
2. Check for security issues (see references/security.md)
3. Check for performance issues
4. Generate report

## Output Format
- Summary of findings
- Severity ratings
- Suggested fixes
```
