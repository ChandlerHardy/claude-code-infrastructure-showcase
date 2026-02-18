# Claude Code Infrastructure Showcase

**A curated reference library of production-tested Claude Code infrastructure.**

Born from 6+ months of real-world use, this showcase provides patterns and systems for skill creation, safety guardrails, structured development workflows, and autonomous iteration.

> **This is NOT a working application** - it's a reference library. Copy what you need into your own projects.

---

## What's Inside

### Core Infrastructure
- **Skills with frontmatter-based activation** (description = trigger, no hooks needed)
- **Modular skill pattern** (500-line rule with progressive disclosure)
- **Specialized agents** for complex tasks
- **Dev docs system** that survives context resets
- **Skill frontmatter hooks** (`once: true`, `PreToolUse`, `Stop`) for distributed enforcement
- **Utility hooks** (PostToolUse tracking, SessionStart branch detection, Stop reminders)

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

### I want to add skills to my workflow

**How it works:** Skills activate via their YAML frontmatter `description` field. Claude sees the description in its system prompt and invokes the skill when relevant. No hooks or config files needed.

**What you need:**
1. A skill directory with a SKILL.md file
2. Proper frontmatter with name + description
3. That's it

**[Skills Guide: .claude/skills/README.md](.claude/skills/README.md)**

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

7-phase workflow with specialized agents: Discovery > Exploration > Questions > Architecture > Implementation > Review > Summary.

**[Feature Dev Plugin: .claude/skills/feature-dev/](.claude/skills/feature-dev/)**

### I want autonomous iteration (ralph-loop)

Uses Stop hooks to block Claude from finishing until completion criteria are met — self-referential feedback loops for autonomous task completion.

**[Ralph Loop Plugin: .claude/skills/ralph-loop/](.claude/skills/ralph-loop/)**

### I want to browse skills

Browse the [skills catalog](.claude/skills/) and copy what you need.

**[Skills Guide: .claude/skills/README.md](.claude/skills/README.md)**

---

## How Skill Activation Works

Skills activate via their **frontmatter description**. No hooks, no config files, no external tooling.

```yaml
---
name: managing-dev-docs
description: Use when starting complex multi-step tasks, resuming work after context loss, or when user mentions committing changes. Triggers on commit, committed, done, push, implement, create, add feature, continue, resume.
---
```

Claude sees this in its system prompt as:
```
- managing-dev-docs: Use when starting complex multi-step tasks, resuming work after context loss, or when user mentions committing changes...
```

When the user's prompt matches the description, Claude invokes the skill automatically.

### Writing Good Descriptions

The `description` field (max 1024 chars) IS the trigger mechanism:

- Start with "Use when..." to frame activation conditions
- Include specific keywords users would say
- Mention timing ("before writing code", "after completing tasks")
- Include synonyms (commit/committed/push/done)

### Frontmatter Hooks (Optional Enhancement)

Skills can self-enforce via inline hooks for additional control:

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

- **`once: true`** — Fire only once per session
- **`PreToolUse`** — Check before file edits
- **`Stop`** — Verify before session ends

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
│   ├── skill-developer/             [user-level]
│   ├── playwright-cli/              [user-level] (7 references)
│   ├── refactoring-patterns/        [project-level]
│   ├── project-guidelines-generator/ [user-level] Meta-skill (3 resources)
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
│   └── ralph-loop/                  [plugin] Autonomous iteration
│       ├── hooks/                   Stop hook for completion checking
│       ├── scripts/                 Setup script
│       └── commands/                /ralph-loop, /cancel-ralph
│
├── other-skills/               # Stack-specific reference skills
│   └── php-backend-dev-guidelines/
│
├── hooks/                      # Utility hooks (non-activation)
│   ├── post-tool-use-tracker.sh     (tracks edited files)
│   ├── dev-docs-stop-hook.sh        (reminds about dev doc updates)
│   └── dev-docs-branch-init.sh      (detects feature branches on session start)
│
├── agents/                     # 10+ specialized agents
│   ├── code-architecture-reviewer.md
│   ├── refactor-planner.md
│   ├── web-research-specialist.md
│   └── ...
│
└── commands/                   # Slash commands
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
| [**project-guidelines-generator**](.claude/skills/project-guidelines-generator/) | Meta | Scan any project and generate tailored guidelines skill | User |
| [**managing-dev-docs**](.claude/skills/managing-dev-docs/) | Productivity | Track features across sessions | User |
| [**code-review-local**](.claude/skills/code-review-local/) | Quality | 8-agent code review with auto-detection of project-level guidelines | Project |
| [**backend-dev-guidelines**](.claude/skills/backend-dev-guidelines/) | Domain | Express/Prisma/Sentry patterns | Project |
| [**frontend-dev-guidelines**](.claude/skills/frontend-dev-guidelines/) | Domain | React/MUI v7/TypeScript | Project |
| [**route-tester**](.claude/skills/route-tester/) | Domain | Testing authenticated routes | Project |
| [**error-tracking**](.claude/skills/error-tracking/) | Observability | Sentry integration | Project |
| [**playwright-cli**](.claude/skills/playwright-cli/) | Automation | Browser testing via Playwright | User |
| [**refactoring-patterns**](.claude/skills/refactoring-patterns/) | Quality | Code duplication & smell analysis | Project |

### Hooks

| Hook | Event | Purpose |
|------|-------|---------|
| post-tool-use-tracker | PostToolUse | Track file changes for dev docs stop hook |
| dev-docs-stop-hook | Stop | Remind about dev doc updates when session ends |
| dev-docs-branch-init | SessionStart | Detect feature branches, show dev doc progress |
| hookify hooks | PreToolUse/PostToolUse/Stop | Safety guardrails (via hookify plugin) |
| ralph-loop stop-hook | Stop | Autonomous iteration |

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
| /route-research-for-testing | Research route patterns for testing |
| /hookify | Create safety guardrail rules |
| /feature-dev | Launch structured development workflow |
| /ralph-loop | Start autonomous iteration loop |

---

## Dev Docs Pattern

Three-file structure that survives context resets:
- `plan.md` - Strategic plan
- `context.md` - Key decisions and files
- `tasks.md` - Checklist format

Stored in `~/.claude/dev-docs/{project}/{feature}/` and managed by the `managing-dev-docs` skill.

---

## Integration Workflow

### Phase 1: Add Your First Skill (10 min)
1. Pick ONE relevant skill from the catalog
2. Copy skill directory to `~/.claude/skills/` (user-level) or `.claude/skills/` (project-level)
3. Restart Claude Code
4. Test by prompting with trigger keywords

### Phase 2: Optional Enhancements
- Add hookify for safety guardrails
- Add feature-dev for structured workflows
- Add ralph-loop for autonomous iteration
- Add agents for complex tasks
- Add utility hooks (PostToolUse tracker, dev docs Stop hook)

---

## What Won't Work As-Is

- **settings.json** — Example only, references example services
- **Blog domain examples** — Teaching examples, adapt to your domain
- **Stack-specific skills** — Node.js/Express/React patterns, adapt for your stack

---

## What This Solves

| Before | After |
|--------|-------|
| Skills don't activate automatically | Frontmatter descriptions trigger skills contextually |
| Have to remember which skill to use | Claude matches prompt to skill descriptions |
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
This infrastructure was detailed in ["Claude Code is a Beast -- Tips from 6 Months of Hardcore Use"](https://www.reddit.com/r/ClaudeAI/comments/1oivjvm/claude_code_is_a_beast_tips_from_6_months_of/) on Reddit. After hundreds of requests, this showcase was created to help the community implement these patterns.

**Recommended companion skills:** See [RECOMMENDED_SKILLS.md](RECOMMENDED_SKILLS.md) for a curated list of community skills that complement this showcase, with an [install script](scripts/install-recommended-skills.sh) for standalone skills.

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
- [Recommended Community Skills](RECOMMENDED_SKILLS.md)

**Start here:** Copy one skill directory, restart Claude Code, and see the activation magic happen.
