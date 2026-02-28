---
name: managing-dev-docs
description: Use when starting complex multi-step tasks, resuming work after context loss, or when user mentions committing changes. Triggers on commit, committed, done, push, implement, create, add feature, continue, resume, pick up where we left off. Creates three companion documents (task plan, context file, tasks checklist) to maintain continuity across sessions and prevent context loss. After commits, update tasks.md progress and context.md with what changed.
---

# Managing Dev Docs

## Overview

Dev docs are three companion markdown files that prevent context loss during complex tasks. They capture plan, context, and progress so work survives session boundaries and context compaction.

## When to Use

**Use dev docs for ANY of these:**
- Task requires 3+ implementation steps (including: write code, test, update docs, review)
- Work will span multiple sessions
- Resuming work after context loss/compaction
- Managing concurrent features
- User asks to "implement", "add", "create" a feature (even if seems simple)

**What counts as 3+ steps:**
- Single function = (1) write function, (2) test it, (3) integrate it = 3 steps ✓
- Bug fix = (1) reproduce, (2) fix, (3) verify = 3 steps ✓
- "Quick change" = Still needs tracking if you might forget it ✓

**Always check for existing dev docs when:**
- User says "continue" or "resume" work
- User references previous incomplete work
- Starting a session with no context

## The Three Documents

Dev docs live in `~/.claude/dev-docs/{project-name}/{feature-name}/`:

1. **`plan.md`** - Accepted implementation strategy
2. **`context.md`** - Key files, decisions, discoveries
3. **`tasks.md`** - Enumerated checklist of work items

## Workflow

### Starting New Feature

1. Use planning mode to research and develop strategy
2. Create dev docs directory: `~/.claude/dev-docs/{project}/{feature}/`
3. Write all three documents based on plan
4. Mark first task as in_progress in `tasks.md`
5. Begin implementation

### During Implementation

1. Mark tasks complete immediately in `tasks.md` when done
2. Update `context.md` with discoveries, key files, decisions
3. DO NOT skip updating docs "because it's obvious" or "to save time"

### When User Mentions Commit

When user says "I've committed", "committed", or indicates they've committed changes:

1. **Update progress immediately** - Mark completed tasks in `tasks.md`
2. **Document changes** - Update `context.md` with what was implemented
3. **Record outcomes** - Add results, bugs found, lessons learned
4. **Next steps** - Note what remains to be done

### Before Context Compaction

1. Update `context.md` with current state and next steps
2. Mark current progress in `tasks.md`
3. Commit all dev docs

### Resuming Work

1. **Search for dev docs** - Don't assume exact path, search the directory
2. **Read all files** - Read plan.md, context.md, tasks.md before asking user
3. **Create if missing** - If no docs exist but work is incomplete, create them now

#### Finding Dev Docs (CRITICAL)

When user mentions a feature/branch, **DO NOT GUESS the exact path**. Instead:

**Step 1: List project dev docs**
```bash
ls -la ~/.claude/dev-docs/{project-name}/ 2>/dev/null || echo "No dev docs"
```

**Step 2: Search for similar names**
```bash
# Case-insensitive search for feature keywords
find ~/.claude/dev-docs/{project-name}/ -maxdepth 1 -type d -iname "*keyword*"
```

**Examples:**
- User says "custom nav bar" → Search for `*custom*`, `*nav*`, `*bar*`
- User says "feature/custom-nav-bar" → Try variations: `custom-nav-bar`, `customizable-nav-bar`, `navigation-bar`
- Branch differs from folder → Match on keywords, not exact name

**Common Mismatches:**
- Branch: `feature/custom-nav-bar` → Folder: `customizable-navigation-bar`
- Branch: `fix/bug-123` → Folder: `bug-123-fix`
- User says: "the dashboard thing" → Folder: `consultant-dashboard`

**Always search first, then read. Never assume exact path.**

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| "I'll track it mentally" | Complex tasks exceed working memory. Write it down. |
| "Too urgent for docs" | Context loss costs more time than 2min creating docs. |
| "Let me ask user for context" | Check dev docs first. User shouldn't repeat themselves. |
| "This is too simple" | Single functions need docs too. No exceptions. |
| "Build is broken, skip process" | Broken builds need tracking MORE, not less. |
| "Just one quick thing" | Quick things forgotten fastest. Document it. |
| "File doesn't exist at exact path" | SEARCH the directory first. Branch names ≠ folder names. |

## No Exceptions

**There are NO valid reasons to skip dev docs when criteria match.**

Not for:
- "Emergency" situations
- "Simple" tasks
- "Just a single function"
- "Quick fixes"
- Time pressure

**Violating the letter of the rules is violating the spirit of the rules.**

## Red Flags - Create Dev Docs Now

- "Continue working on..."
- "Resume that feature..."
- Task has 3+ steps
- User mentions previous incomplete work
- Any multi-session work

**All of these mean: Check for or create dev docs.**

## Quick Reference

| Action | Command |
|--------|---------|
| Find docs | `ls -la ~/.claude/dev-docs/{project}/` then search for similar names |
| Create docs | `~/.claude/dev-docs/{project}/{feature}/` with plan.md, context.md, tasks.md |
| Resume work | Search → Read all three files → Continue (never ask user first) |
| During work | Mark tasks complete immediately |

## Real-World Impact

Prevents "What were we working on?" conversations and saves hours re-explaining context after compaction. Enables seamless session handoff for complex work spanning days/weeks.
