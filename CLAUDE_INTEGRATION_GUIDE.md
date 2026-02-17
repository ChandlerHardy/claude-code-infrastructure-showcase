# Claude Integration Guide

**FOR CLAUDE CODE:** When a user asks you to integrate components from this showcase repository into their project, follow these instructions carefully.

---

## Overview

This repository is a **reference library** of Claude Code infrastructure components. Users will ask you to help integrate specific pieces into their projects. Your role is to:

1. **Ask clarifying questions** about their project structure
2. **Copy the appropriate files**
3. **Customize content** for their setup
4. **Verify the integration** works correctly

**Key Principle:** ALWAYS ask before assuming project structure. What works for one project won't work for another.

---

## How Skills Work

Skills activate via their **frontmatter description**. No config files, no hooks needed for activation.

```yaml
---
name: my-skill
description: Use when [specific scenarios]. Triggers on [keywords]. [What it does].
---

# Skill content here...
```

Claude sees the description in its system prompt and invokes the skill when the user's prompt matches.

---

## Tech Stack Compatibility Check

**CRITICAL:** Before integrating a skill, verify the user's tech stack matches the skill requirements.

### Frontend Skills

**frontend-dev-guidelines requires:** React (18+), MUI v7, TanStack Query/Router, TypeScript

**Before integrating, ask:** "Do you use React with MUI v7?"

**If NO:** Offer to adapt the skill as a template for their stack, extract framework-agnostic patterns, or skip.

### Backend Skills

**backend-dev-guidelines requires:** Node.js/Express, TypeScript, Prisma ORM, Sentry

**Before integrating, ask:** "Do you use Node.js with Express and Prisma?"

**If NO:** Offer to adapt for their stack or extract architecture patterns (layered architecture works for any framework).

### Tech-Agnostic Skills (Copy As-Is)

- **skill-developer** — Meta-skill, no tech requirements
- **managing-dev-docs** — Feature tracking across sessions
- **code-review-local** — 7-agent code review pipeline
- **refactoring-patterns** — Code duplication analysis
- **playwright-cli** — Browser automation

---

## Integrating Skills

### Step-by-Step Process

#### 1. Understand Their Project

**ASK:**
- "What's your project structure? Single app, monorepo, or multi-service?"
- "Where is your [backend/frontend] code located?"
- "What frameworks/technologies do you use?"

#### 2. Copy the Skill

**For project-specific skills:**
```bash
cp -r /path/to/showcase/.claude/skills/[skill-name] \
      $CLAUDE_PROJECT_DIR/.claude/skills/
```

**For user-level skills (managing-dev-docs, skill-developer):**
```bash
cp -r /path/to/showcase/.claude/skills/[skill-name] \
      ~/.claude/skills/
```

#### 3. Customize Content

If the skill references specific tech that doesn't match the user's stack, adapt the content. The frontmatter description may also need updating to reflect their domain.

#### 4. Verify

```bash
# Check skill was copied
ls -la $CLAUDE_PROJECT_DIR/.claude/skills/[skill-name]/SKILL.md

# Restart Claude Code to pick up new skills
```

**Tell user:** "Restart Claude Code, then try prompting with relevant keywords to verify the skill activates."

---

## Skill-Specific Notes

| Skill | Requirements | Ask Before Integrating |
|-------|-------------|----------------------|
| **backend-dev-guidelines** | Express/Prisma/Sentry | "Do you use Express with Prisma?" |
| **frontend-dev-guidelines** | React/MUI v7/TanStack | "Do you use React with MUI v7?" |
| **route-tester** | JWT cookie auth | "Do you use JWT cookie-based authentication?" |
| **error-tracking** | Sentry | "Do you use Sentry?" |
| **skill-developer** | None | Copy as-is |
| **managing-dev-docs** | None | Copy as-is |
| **code-review-local** | None | Copy as-is |
| **refactoring-patterns** | None | Copy as-is |
| **playwright-cli** | None | Copy as-is |

---

## Adapting Skills for Different Tech Stacks

### Option 1: Adapt Existing Skill (Recommended)

1. Copy the skill as a starting point
2. Keep framework-agnostic patterns (file organization, architecture, testing strategy)
3. Replace framework-specific code examples
4. Update the frontmatter description for the new stack

### Option 2: Extract Framework-Agnostic Patterns

Create a new skill with just the transferable patterns:
- Layered architecture (Routes > Controllers > Services)
- Separation of concerns
- Error handling philosophy
- Testing strategies

### What Transfers Across Stacks

| Transfers | Doesn't Transfer |
|-----------|-----------------|
| Layered architecture | React hooks |
| File organization patterns | MUI components |
| Testing strategies | Prisma query syntax |
| Error handling philosophy | Express middleware |
| TypeScript best practices | Framework-specific routing |

---

## Integrating Hooks (Optional)

Hooks are **not required for skill activation** but are useful for utility purposes.

### Utility Hooks (Safe to Copy)

| Hook | Purpose | Customization |
|------|---------|--------------|
| **post-tool-use-tracker.sh** | Tracks edited files for dev docs | None needed |
| **dev-docs-stop-hook.sh** | Reminds about dev doc updates | None needed |
| **dev-docs-branch-init.sh** | Detects feature branches on start | None needed |

**Add to settings.json:**
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|MultiEdit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/post-tool-use-tracker.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/dev-docs-stop-hook.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/dev-docs-branch-init.sh"
          }
        ]
      }
    ]
  }
}
```

---

## Integrating Agents

**Agents are STANDALONE** — easiest to integrate!

```bash
cp showcase/.claude/agents/[agent-name].md \
   $CLAUDE_PROJECT_DIR/.claude/agents/
```

**Check for hardcoded paths** in agent files and update them to match the user's project structure.

---

## Common Mistakes to Avoid

| Mistake | Fix |
|---------|-----|
| Copy settings.json as-is | Extract only the sections they need |
| Keep example service names | Ask about their actual structure |
| Skip making hooks executable | Always `chmod +x` after copying |
| Assume monorepo structure | Ask first, then customize |
| Add all skills at once | Start with one relevant skill |

---

## Quick Reference

| Component | Integration Steps |
|-----------|------------------|
| **Skill** | Copy directory > restart Claude Code > test |
| **Agent** | Copy .md file > check paths > done |
| **Hook** | Copy script > chmod +x > add to settings.json |
| **Plugin** | Use showcase as reference only; install via `/plugin` marketplace |

**Always explain what you're doing and provide clear next steps after integration.**
