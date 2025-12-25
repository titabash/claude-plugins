---
name: design-guideline
description: UI design guideline for {{PROJECT_NAME}}. Defines color, typography, spacing, and component specifications. Use when developing UI components, styling elements, or making design decisions for this project.
---

# {{PROJECT_NAME}} Design Guideline

Platform: {{PLATFORM}}
Accessibility: {{ACCESSIBILITY_LEVEL}}

## Quick Reference

| Category | Overview | Details |
|----------|----------|---------|
| Colors | Primary: {{PRIMARY_COLOR}} | [colors.md](references/colors.md) |
| Typography | {{FONT_FAMILY_SHORT}} | [typography.md](references/typography.md) |
| Spacing | 8px base | [spacing.md](references/spacing.md) |
| Components | 20+ defined | [components.md](references/components.md) |

## Color System (Overview)

- **Primary**: {{PRIMARY_COLOR}} - Main brand color
- **Secondary**: {{SECONDARY_COLOR}} - Sub color
- **Gray**: #6B7280 - Text and borders
- **Semantic**: Success/Warning/Error/Info

See [references/colors.md](references/colors.md) for details

## Typography (Overview)

- **Font**: {{FONT_FAMILY_SHORT}}
- **Scale**: xs(12px) sm(14px) base(16px) lg(18px) xl(20px) 2xl(24px) 3xl(30px) 4xl(36px)

See [references/typography.md](references/typography.md) for details

## Spacing (Overview)

8px base system: 0, 4, 8, 12, 16, 24, 32, 48, 64, 96px

See [references/spacing.md](references/spacing.md) for details

## Components (Overview)

### Input Components
Button, Input, Textarea, Select, Checkbox, Radio, Switch

### Feedback Components
Alert, Toast, Badge, Tag, Tooltip

### Layout Components
Card, Modal, Drawer, Tabs, Navigation

### Data Display Components
Table, List, Pagination, Avatar

See [references/components.md](references/components.md) for details

## Design Tokens

See [references/tokens.json](references/tokens.json)

## Usage Notes

1. **When implementing components**: Always refer to the references above
2. **When using colors**: Check contrast ratio (WCAG {{ACCESSIBILITY_LEVEL}} compliant)
3. **Spacing**: Use multiples of 8px
4. **Fonts**: Use the specified scale
