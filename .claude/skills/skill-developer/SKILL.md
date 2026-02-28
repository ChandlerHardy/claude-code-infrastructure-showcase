---
name: skill-developer
description: Create and manage Claude Code skills following best practices. Use when creating new skills, editing existing skills, understanding skill activation, working with frontmatter hooks, or debugging why a skill isn't triggering. Covers skill structure, YAML frontmatter, the description-as-trigger pattern, frontmatter hooks (once, PreToolUse, Stop), progressive disclosure, and the 500-line rule.
---

# Skill Developer Guide

## Purpose

Guide for creating and managing skills in Claude Code, following best practices including the 500-line rule and progressive disclosure pattern.

## When to Use This Skill

- Creating or adding new skills
- Editing existing skill descriptions or triggers
- Understanding how skill activation works
- Debugging skill activation issues
- Working with frontmatter hooks
- Progressive disclosure patterns

---

## How Skill Activation Works

Skills activate via their **frontmatter description**. Claude sees each skill's description in the system prompt as a "Use when..." line. When a user's prompt matches, Claude invokes the skill.

**The description IS the trigger.** There is no separate config file or hook needed.

### Example

```yaml
---
name: systematic-debugging
description: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
---
```

Claude sees in system prompt:
```
- systematic-debugging: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
```

When user says "this test is failing", Claude recognizes the match and invokes the skill.

### Writing Effective Descriptions

The description field (max 1024 chars) determines when your skill activates. Make it explicit:

**Good descriptions:**
```yaml
# Explicit trigger words + clear context
description: Use when starting complex multi-step tasks, resuming work after context loss, or when user mentions committing changes. Triggers on commit, committed, done, push, implement, create, add feature, continue, resume.

# Action-oriented with specific scenarios
description: Use when implementing any feature or bugfix, before writing implementation code

# Clear boundary of when to activate
description: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
```

**Bad descriptions:**
```yaml
# Too vague — when does this fire?
description: General development guidelines

# Too narrow — misses valid triggers
description: Use when user says "run tests"

# No trigger context
description: Backend development patterns for Node.js
```

**Tips:**
- Start with "Use when..." to frame the trigger condition
- Include specific keywords users would say (commit, debug, test, deploy)
- Mention the timing ("before writing code", "after completing tasks")
- Include synonyms and variations (commit/committed/push/done)

---

## Quick Start: Creating a New Skill

### Step 1: Create the Skill File

**Location:** `~/.claude/skills/{skill-name}/SKILL.md` (user-level) or `.claude/skills/{skill-name}/SKILL.md` (project-level)

```markdown
---
name: my-new-skill
description: Use when [specific scenarios]. Triggers on [keywords]. [What it does].
---

# My New Skill

## Purpose
What this skill helps with

## When to Use
Specific scenarios and conditions

## Key Information
The actual guidance, patterns, examples
```

### Step 2: Done

That's it. The frontmatter description is the trigger. Claude will see it in the system prompt and invoke it when relevant.

### Step 3 (Optional): Add Frontmatter Hooks

For skills that need enforcement beyond simple activation:

```yaml
---
name: frontend-dev-guidelines
description: React/TypeScript best practices
once: true
hooks:
  PreToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: prompt
          prompt: "Verify MUI v7 patterns: Grid uses size={{}} prop, NOT xs/sm props."
---
```

---

## Skill Structure

### The 500-Line Rule

Keep SKILL.md under 500 lines. Use reference files for details.

```
skill-name/
  SKILL.md              # <500 lines — loaded first
  resources/             # Additional detail, loaded on demand
    topic-1.md           # <500 lines each
    topic-2.md
```

**Progressive disclosure:** Claude loads the main skill first, then loads resources only when deeper detail is needed.

### Best Practices

- **Name**: Lowercase, hyphens, gerund form preferred (e.g., "managing-dev-docs")
- **Description**: Include ALL trigger keywords/phrases (max 1024 chars)
- **Content**: Under 500 lines — use reference files for details
- **Examples**: Include real code examples
- **Structure**: Clear headings, lists, code blocks
- **Table of contents**: Add to reference files over 100 lines

---

## Frontmatter Hooks

Skills can self-enforce via inline hooks in their frontmatter:

### `once: true`

Fire the skill only once per session (prevents nagging):

```yaml
---
name: frontend-dev-guidelines
description: React/TypeScript best practices
once: true
---
```

### PreToolUse Hooks

Run a check before tool execution:

```yaml
---
hooks:
  PreToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: prompt
          prompt: "Before editing, verify: correct naming conventions, proper error handling."
---
```

### Stop Hooks

Verify something before the session ends:

```yaml
---
hooks:
  Stop:
    - hooks:
        - type: prompt
          prompt: "Before finishing, have you updated dev docs with your changes?"
---
```

### Combining

```yaml
---
name: my-skill
description: Use when doing X
once: true
hooks:
  PreToolUse:
    - matcher: "Edit"
      hooks:
        - type: prompt
          prompt: "Check Y before editing"
  Stop:
    - hooks:
        - type: prompt
          prompt: "Verify Z before stopping"
---
```

---

## Skill Locations

| Location | Scope | Example |
|----------|-------|---------|
| `~/.claude/skills/` | User-level — all projects | managing-dev-docs, skill-developer |
| `.claude/skills/` | Project-level — one repo | backend-dev-guidelines, error-tracking |
| Plugins (superpowers, etc.) | Plugin-managed — installed via `/plugin` | TDD, systematic-debugging |

**User-level** for skills useful everywhere. **Project-level** for stack-specific skills.

---

## Debugging Activation

### Skill Not Triggering?

1. **Check frontmatter exists** — SKILL.md must have `---` delimited YAML at the top
2. **Check description** — Does it include the keywords the user would say?
3. **Check skill appears in system prompt** — Look for it in the skills list
4. **Restart Claude Code** — New/edited skills require restart to appear
5. **Check file location** — Must be in `~/.claude/skills/` or `.claude/skills/`
6. **Check directory structure** — Must be `{skill-name}/SKILL.md`, not just `SKILL.md`

### Skill Triggering Too Often?

1. **Narrow the description** — Remove generic words, add specific context
2. **Add "Use when..." framing** — Makes activation conditional
3. **Use `once: true`** — Prevents repeated activation in same session

### Skill Not Loading Content?

1. **Check file is under 500 lines** — Oversized skills may be truncated
2. **Check reference file paths** — Relative paths from skill directory
3. **Verify markdown formatting** — Broken YAML frontmatter prevents loading

---

## Checklist

When creating a new skill:

- [ ] SKILL.md created in correct location
- [ ] Frontmatter has `name` and `description`
- [ ] Description includes trigger keywords and "Use when..." framing
- [ ] Content under 500 lines
- [ ] Reference files created if needed (with table of contents for 100+ lines)
- [ ] Tested: restart Claude Code and verify skill appears in system prompt
- [ ] Tested: prompt with trigger keywords and verify skill activates

---

## Related Infrastructure

**Hooks (still useful for non-skill automation):**
- `PostToolUse` — Track file changes after edits
- `Stop` — Remind about dev docs before session ends
- `SessionStart` — Detect feature branches and show dev doc progress

**Plugins:**
- Install via `/plugin` command
- Managed separately from manual skills
- Examples: superpowers (TDD, debugging, code review)

---

**Line Count**: < 500 (following 500-line rule)
