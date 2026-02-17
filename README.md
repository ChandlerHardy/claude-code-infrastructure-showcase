# Claude Code Infrastructure Showcase

**A curated reference library of production-tested Claude Code infrastructure.**

Born from 6+ months of real-world use and updated for Claude Code v2.1.3+, this showcase provides patterns and systems for skill auto-activation, safety guardrails, structured development workflows, and autonomous iteration — solving the core problem that skills don't activate on their own.

> **This is NOT a working application** - it's a reference library. Copy what you need into your own projects.

---

## What's Inside

### Core Infrastructure
- **Auto-activating skills** via UserPromptSubmit hooks with imperative enforcement
- **Modular skill pattern** (500-line rule with progressive disclosure)
- **Specialized agents** for complex tasks
- **Dev docs system** that survives context resets
- **Skill frontmatter hooks** (`once: true`, `PreToolUse`, `Stop`) for distributed enforcement

### Official Anthropic Plugins
- **hookify** — No-code safety guardrails via markdown config files
- **feature-dev** — 7-phase structured development workflow with specialized agents
- **ralph-loop** — Autonomous iteration via Stop hooks until completion criteria met

### Community Patterns
- **Browser automation** via Playwright CLI skill + Brave extension mode wrapper
- **Comprehensive examples** using generic blog domain
- **Utility scripts** for provider switching and browser automation

**Time to integrate into your project:** 15-30 minutes

---

## Quick Start - Pick Your Path

### Using Claude Code to Integrate?

Read [`CLAUDE_INTEGRATION_GUIDE.md`](CLAUDE_INTEGRATION_GUIDE.md) for step-by-step integration instructions tailored for AI-assisted setup.

### I want skill auto-activation

**The breakthrough feature:** Skills that actually activate when you need them.

**What you need:**
1. The skill-activation hooks (2 files)
2. A skill or two relevant to your work
3. 15 minutes

**[Setup Guide: .claude/hooks/README.md](.claude/hooks/README.md)**

### I want safety guardrails (hookify)

Prevent dangerous behaviors (rm -rf, credential commits, etc.) with no-code markdown rules:

```markdown
---
name: warn-dangerous-rm
enabled: true
event: bash
pattern: rm\s+-rf
---
Dangerous rm command detected. Verify the path before proceeding.
```

**[Hookify Plugin: .claude/skills/hookify/](.claude/skills/hookify/)**

### I want structured feature development

7-phase workflow with specialized agents: Discovery → Exploration → Questions → Architecture → Implementation → Review → Summary.

**[Feature Dev Plugin: .claude/skills/feature-dev/](.claude/skills/feature-dev/)**

### I want autonomous iteration (ralph-loop)

Uses Stop hooks to block Claude from finishing until completion criteria are met — self-referential feedback loops for autonomous task completion.

**[Ralph Loop Plugin: .claude/skills/ralph-loop/](.claude/skills/ralph-loop/)**

### I want to browse skills

Browse the [skills catalog](.claude/skills/) and copy what you need.

**[Skills Guide: .claude/skills/README.md](.claude/skills/README.md)**

---

## What Makes This Different?

### Imperative Skill Enforcement (v2.0)

**Problem:** Passive skill suggestions ("consider using...") get ignored ~80% of the time.

**Solution:** The UserPromptSubmit hook now uses imperative language for critical/high priority skills:

```
MANDATORY SKILL INVOCATION REQUIRED

You MUST use the Skill tool to invoke the following skills BEFORE generating any other response.
This is a BLOCKING REQUIREMENT — do NOT skip, summarize, or respond without invoking these skills first.

  INVOKE: Skill("managing-dev-docs")
```

**Result:** ~80%+ activation rate, up from ~20% with passive suggestions.

### Skill Frontmatter Hooks (v2.1.3+)

Skills can now define their own hooks inline, bundling enforcement with the skill itself:

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

**Supported frontmatter fields:**
- `once: true` — Only fire once per session (prevents nagging)
- `hooks.PreToolUse` — Run before tool execution
- `hooks.Stop` — Run when Claude tries to finish

### Tightened Trigger Keywords (v2.0)

**Problem:** Broad keywords like `"code"`, `"error"`, `"done"` caused skills to fire on nearly every prompt.

**Solution:** Multi-word phrases that match intent, not individual words:

| Before (too broad) | After (specific) |
|-------------------|-----------------|
| `"error"`, `"bug"`, `"debug"` | `"sentry"`, `"captureException"`, `"error tracking"` |
| `"done"`, `"ready"`, `"go ahead"` | `"code review"`, `"review changes"`, `"review before commit"` |
| `"code"`, `"development"` | `"design pattern"`, `"solid principles"` |

### Two-Tier Code Review Strategy

| Tier | Tool | When | Speed |
|------|------|------|-------|
| **Per-commit** | `code-architecture-reviewer` Task agent | Every commit | ~30-60 seconds |
| **Milestone** | `code-review-local` skill (7 parallel agents) | Phase completions, pre-deploy | ~3-5 minutes |

### Modular Skills (500-Line Rule)

```
skill-name/
  SKILL.md                  # <500 lines, high-level guide
  resources/
    topic-1.md              # <500 lines each
    topic-2.md
```

**Progressive disclosure:** Claude loads main skill first, loads resources only when needed.

---

## Repository Structure

```
.claude/
├── skills/                     # Skills library
│   ├── backend-dev-guidelines/      [project-level] (12 resources)
│   ├── frontend-dev-guidelines/     [project-level] (11 resources, once: true + PreToolUse hook)
│   ├── code-review-local/           [project-level] (Stop hook for review reminder)
│   ├── error-tracking/              [project-level]
│   ├── route-tester/                [project-level]
│   ├── managing-dev-docs/           [user-level]
│   ├── skill-developer/             [user-level] (7 resources)
│   ├── playwright-cli/              [user-level] (7 references)
│   ├── refactoring-patterns/        [project-level]
│   ├── api-development/             [project-level]
│   ├── general-development/         [project-level]
│   │
│   ├── hookify/                     [plugin] Safety guardrails system
│   │   ├── hooks/                   Python hook handlers
│   │   ├── core/                    Rule engine + config loader
│   │   ├── commands/                /hookify, /hookify:list, /hookify:configure, /hookify:help
│   │   ├── agents/                  conversation-analyzer
│   │   ├── skills/writing-rules/    Rule authoring guide
│   │   └── examples/               4 example rules
│   │
│   ├── feature-dev/                 [plugin] Structured development workflow
│   │   ├── agents/                  code-explorer, code-architect, code-reviewer
│   │   └── commands/                /feature-dev
│   │
│   ├── ralph-loop/                  [plugin] Autonomous iteration
│   │   ├── hooks/                   Stop hook for completion checking
│   │   ├── scripts/                 Setup script
│   │   └── commands/                /ralph-loop, /cancel-ralph
│   │
│   └── skill-rules.json            Trigger configuration (v2.0)
│
├── other-skills/               # Stack-specific reference skills
│   ├── mixed-stack-guidelines/
│   └── php-backend-dev-guidelines/
│
├── hooks/                      # Core automation hooks
│   ├── skill-activation-prompt.*    (ESSENTIAL - imperative enforcement)
│   ├── post-tool-use-tracker.sh     (ESSENTIAL)
│   └── optional/                    Stop hooks, build checks
│
├── agents/                     # 10+ specialized agents
│   ├── code-architecture-reviewer.md
│   ├── refactor-planner.md
│   ├── web-research-specialist.md
│   └── ...
│
└── commands/                   # Slash commands
    ├── dev-docs.md
    ├── dev-docs-update.md
    └── route-research-for-testing.md

scripts/
├── claude-provider             # Provider switcher (Anthropic/Z.AI)
└── playwright-brave            # Brave browser extension mode wrapper
```

---

## Component Catalog

### Skills

| Skill | Type | Purpose | Location |
|-------|------|---------|----------|
| [**hookify**](.claude/skills/hookify/) | Plugin | No-code safety guardrails via markdown rules | Project |
| [**feature-dev**](.claude/skills/feature-dev/) | Plugin | 7-phase structured development with agents | Project |
| [**ralph-loop**](.claude/skills/ralph-loop/) | Plugin | Autonomous iteration via Stop hooks | Project |
| [**skill-developer**](.claude/skills/skill-developer/) | Meta | Creating and managing skills | User |
| [**managing-dev-docs**](.claude/skills/managing-dev-docs/) | Productivity | Track features across sessions | User |
| [**code-review-local**](.claude/skills/code-review-local/) | Quality | 7-agent code review pipeline | Project |
| [**backend-dev-guidelines**](.claude/skills/backend-dev-guidelines/) | Domain | Express/Prisma/Sentry patterns | Project |
| [**frontend-dev-guidelines**](.claude/skills/frontend-dev-guidelines/) | Domain | React/MUI v7/TypeScript | Project |
| [**route-tester**](.claude/skills/route-tester/) | Domain | Testing authenticated routes | Project |
| [**error-tracking**](.claude/skills/error-tracking/) | Observability | Sentry integration | Project |
| [**playwright-cli**](.claude/skills/playwright-cli/) | Automation | Browser testing via Playwright | User |
| [**refactoring-patterns**](.claude/skills/refactoring-patterns/) | Quality | Code duplication & smell analysis | Project |
| [**api-development**](.claude/skills/api-development/) | Domain | REST/GraphQL patterns | Project |
| [**general-development**](.claude/skills/general-development/) | Domain | Language-agnostic best practices | Project |

### Hooks

| Hook | Event | Essential? | Description |
|------|-------|-----------|-------------|
| skill-activation-prompt | UserPromptSubmit | Yes | Imperative skill enforcement |
| post-tool-use-tracker | PostToolUse | Yes | Track file changes |
| hookify hooks | PreToolUse/PostToolUse/Stop | Optional | Safety guardrails (via hookify plugin) |
| ralph-loop stop-hook | Stop | Optional | Autonomous iteration |

### Agents (10+)

| Agent | Purpose |
|-------|---------|
| code-architecture-reviewer | Review code for architectural consistency |
| code-refactor-master | Plan and execute refactoring |
| documentation-architect | Generate comprehensive documentation |
| frontend-error-fixer | Debug frontend errors |
| plan-reviewer | Review development plans |
| refactor-planner | Create refactoring strategies |
| web-research-specialist | Research technical issues online |
| conversation-analyzer | Analyze conversation for hookify rules |
| code-explorer | Explore codebase for feature-dev |
| code-architect | Design architecture for feature-dev |

### Slash Commands

| Command | Purpose |
|---------|---------|
| /dev-docs | Create structured dev documentation |
| /dev-docs-update | Update docs before context reset |
| /route-research-for-testing | Research route patterns for testing |
| /hookify | Create safety guardrail rules |
| /feature-dev | Launch structured development workflow |
| /ralph-loop | Start autonomous iteration loop |

---

## Key Concepts

### Hooks + skill-rules.json = Auto-Activation

1. **skill-activation-prompt hook** runs on every user prompt
2. Checks **skill-rules.json** for trigger patterns (keywords + intent regex)
3. Critical/high priority skills get imperative "MUST invoke" enforcement
4. Medium/low priority skills get advisory suggestions
5. Skills load only when needed

### Enforcement Hierarchy

| Priority | Output Style | Example |
|----------|-------------|---------|
| critical | "MANDATORY... You MUST invoke" | managing-dev-docs |
| high | "MANDATORY... You MUST invoke" | backend-dev-guidelines |
| medium | "Consider these skills if relevant" | general-development |
| low | "Consider these skills if relevant" | (advisory only) |

### Skill Frontmatter Hooks

Skills can self-enforce via inline hooks (v2.1.3+):
- **`once: true`** — Fire only once per session
- **`PreToolUse`** — Check before file edits
- **`Stop`** — Verify before session ends

### Dev Docs Pattern

Three-file structure that survives context resets:
- `plan.md` - Strategic plan
- `context.md` - Key decisions and files
- `tasks.md` - Checklist format

---

## Integration Workflow

### Phase 1: Skill Activation (15 min)
1. Copy skill-activation-prompt hook files
2. Copy post-tool-use-tracker hook
3. Copy skill-rules.json to `.claude/skills/`
4. Update settings.json with hook paths
5. Install hook dependencies (`npm install` in hooks dir)

### Phase 2: Add First Skill (10 min)
1. Pick ONE relevant skill
2. Copy skill directory
3. Customize path patterns if needed

### Phase 3: Optional Enhancements
- Add hookify for safety guardrails
- Add feature-dev for structured workflows
- Add ralph-loop for autonomous iteration
- Add agents for complex tasks

---

## What Won't Work As-Is

- **settings.json** — Example only, references example services
- **Blog domain examples** — Teaching examples, adapt to your domain
- **Stop hooks** — Expect specific monorepo structure, customize for yours
- **Stack-specific skills** — Node.js/Express/React patterns, adapt for your stack

---

## What This Solves

| Before | After |
|--------|-------|
| Skills don't activate automatically | Skills suggest themselves with imperative enforcement |
| Have to remember which skill to use | Hooks trigger skills at the right time |
| Large skills hit context limits | Modular skills stay under context limits |
| Context resets lose project knowledge | Dev docs preserve knowledge across resets |
| No safety guardrails | hookify prevents dangerous operations |
| Manual step-by-step development | feature-dev structures the workflow |
| No way to enforce completion criteria | ralph-loop iterates until done |

---

## Community

**Found this useful?**

- Star this repo
- Report issues or suggest improvements
- Share your own skills/hooks/agents
- Contribute examples from your domain

**Background:**
This infrastructure was detailed in ["Claude Code is a Beast – Tips from 6 Months of Hardcore Use"](https://www.reddit.com/r/ClaudeAI/comments/1oivjvm/claude_code_is_a_beast_tips_from_6_months_of/) on Reddit. After hundreds of requests, this showcase was created to help the community implement these patterns.

**Recommended companion skills from [obra/superpowers](https://github.com/obra/superpowers):**
- test-driven-development
- systematic-debugging
- dispatching-parallel-agents
- using-git-worktrees
- verification-before-completion
- subagent-driven-development

---

## License

MIT License - Use freely in your projects, commercial or personal.

---

## Quick Links

- [Claude Integration Guide](CLAUDE_INTEGRATION_GUIDE.md) - For AI-assisted setup
- [Skills Documentation](.claude/skills/README.md)
- [Hooks Setup](.claude/hooks/README.md)
- [Agents Guide](.claude/agents/README.md)
- [Utility Scripts](scripts/README.md)

**Start here:** Copy the two essential hooks, add one skill, and see the auto-activation magic happen.
