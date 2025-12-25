---
description: Create a UI design guideline skill and register it to .claude/skills/
argument-hint: "[URL(optional)]"
---

# Create UI Design Guideline Skill

Create a project-specific UI design guideline as a **Claude Code Skill** and register it to `.claude/skills/design-guideline/`.

## Arguments

- URL (optional): $ARGUMENTS

If a URL is provided, analyze that site's design and use it as a base.

## Output Location

```
.claude/
└── skills/
    └── design-guideline/
        ├── SKILL.md              # Main (overview, max 500 lines)
        └── references/
            ├── colors.md         # Color system details
            ├── typography.md     # Typography details
            ├── spacing.md        # Spacing details
            ├── components.md     # Component specifications
            └── tokens.json       # Design tokens
```

## Execution Steps

1. Ask the user the following questions (using AskUserQuestion tool):
   - Project name
   - Target platform (Web/iOS/Android/React Native/Flutter)
   - Primary brand color
   - Accessibility level (WCAG 2.1 AA/AAA)
   - Other requirements

2. Create `.claude/skills/design-guideline/` directory

3. Generate the following files based on collected information:

### SKILL.md (main file, max 500 lines)

```yaml
---
name: design-guideline
description: UI design guideline for {PROJECT_NAME}. Defines color, typography, spacing, and component specifications. Use when developing UI components, styling elements, or making design decisions for this project.
---
```

- Quick reference table
- Overview of each section (with links to references/)

### references/colors.md
- Primary color palette (50-900 scale)
- Secondary color palette
- Grayscale
- Semantic colors (Success/Warning/Error/Info)
- Color tokens by usage

### references/typography.md
- Font family
- Font size scale (xs-6xl)
- Heading styles (H1-H6)
- Line height and letter spacing

### references/spacing.md
- 8px base spacing system
- Grid system
- Breakpoints
- Container widths

### references/components.md
- Button, Input, Textarea, Select
- Checkbox, Radio, Switch
- Card, Modal, Drawer
- Alert, Toast, Badge, Tag
- Avatar, Navigation, Tabs
- Pagination, Table, List, Divider
- Variants, sizes, and states for each component

### references/tokens.json
- Design tokens (JSON format)

## Reference

See skills/ui-design-guideline/SKILL.md for detailed instructions.
