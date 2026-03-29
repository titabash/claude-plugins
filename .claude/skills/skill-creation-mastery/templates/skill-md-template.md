---
name: {{SKILL_NAME}}
description: {{WHAT_DESCRIPTION}}。{{WHEN_DESCRIPTION}}。Use when {{ENGLISH_TRIGGER_CONDITIONS}}.
allowed-tools: {{ALLOWED_TOOLS}}
---

# {{SKILL_TITLE}}

{{OVERVIEW_1_2_SENTENCES}}

## Output Location

```
{{OUTPUT_DIRECTORY_STRUCTURE}}
```

## Execution Flow

### Phase 1: {{PHASE_1_NAME}}

{{PHASE_1_DESCRIPTION}}

AskUserQuestionで以下を確認:
1. {{REQUIRED_INFO_1}}（必須）
2. {{REQUIRED_INFO_2}}
3. {{OPTIONAL_INFO}}（任意）

### Phase 2: {{PHASE_2_NAME}}

Read [references/{{REFERENCE_FILE}}](references/{{REFERENCE_FILE}}) を参照。

{{PHASE_2_INSTRUCTIONS}}

### Phase 3: {{PHASE_3_NAME}}

{{PHASE_3_INSTRUCTIONS}}

AskUserQuestionで設計を確認:
「以下の内容を提案します。変更があれば教えてください」
- {{PROPOSAL_ITEM_1}}
- {{PROPOSAL_ITEM_2}}

### Phase 4: {{PHASE_4_NAME}}

1. Read templates/{{TEMPLATE_FILE}}
2. {{CUSTOMIZATION_INSTRUCTIONS}}
3. Write to {{OUTPUT_PATH}}

### Phase 5: 完了レポート

生成完了を報告:
1. 生成したファイル一覧
2. 各ファイルの概要
3. 次のステップ

## Reference Files

- [references/{{REF_1}}.md](references/{{REF_1}}.md) - {{REF_1_DESCRIPTION}}
- [references/{{REF_2}}.md](references/{{REF_2}}.md) - {{REF_2_DESCRIPTION}}

## Template Files

- [templates/{{TMPL_1}}](templates/{{TMPL_1}}) - {{TMPL_1_DESCRIPTION}}
