# Claude Code Infrastructure Showcase

**A curated reference library of production-tested Claude Code infrastructure.**

Born from 6 months of real-world use managing a complex TypeScript microservices project, this showcase provides the patterns and systems that solved the "skills don't activate automatically" problem and scaled Claude Code for enterprise development.

> **This is NOT a working application** - it's a reference library. Copy what you need into your own projects.

---

## What's Inside

**Production-tested infrastructure for:**
- ✅ **Auto-activating skills** via hooks
- ✅ **Modular skill pattern** (500-line rule with progressive disclosure)
- ✅ **Specialized agents** for complex tasks
- ✅ **Dev docs system** that survives context resets
- ✅ **Utility scripts** for provider switching and infrastructure management
- ✅ **Browser automation** via Playwright CLI skill
- ✅ **Comprehensive examples** using generic blog domain

**Time investment to build:** 6 months of iteration
**Time to integrate into your project:** 15-30 minutes

---

## Quick Start - Pick Your Path

### 🤖 Using Claude Code to Integrate?

**Claude:** Read [`CLAUDE_INTEGRATION_GUIDE.md`](CLAUDE_INTEGRATION_GUIDE.md) for step-by-step integration instructions tailored for AI-assisted setup.

### 🎯 I want skill auto-activation

**The breakthrough feature:** Skills that actually activate when you need them.

**What you need:**
1. The skill-activation hooks (2 files)
2. A skill or two relevant to your work
3. 15 minutes

**👉 [Setup Guide: .claude/hooks/README.md](.claude/hooks/README.md)**

### 📚 I want to add ONE skill

Browse the [skills catalog](.claude/skills/) and copy what you need.

**Available:**
- **backend-dev-guidelines** - Node.js/Express/TypeScript patterns
- **frontend-dev-guidelines** - React/TypeScript/MUI v7 patterns
- **code-review-local** - 7-agent code review pipeline (warn enforcement)
- **skill-developer** - Meta-skill for creating skills (recommended: user-level)
- **managing-dev-docs** - Track features across sessions (recommended: user-level)
- **route-tester** - Test authenticated API routes
- **error-tracking** - Sentry integration patterns
- **playwright-cli** - Browser automation for testing and MR review
- **dev-docs-update** - Update dev docs after commits/deploys

**👉 [Skills Guide: .claude/skills/README.md](.claude/skills/README.md)**

### 🤖 I want specialized agents

10 production-tested agents for complex tasks:
- Code architecture review
- Refactoring assistance
- Documentation generation
- Error debugging
- And more...

**👉 [Agents Guide: .claude/agents/README.md](.claude/agents/README.md)**

### 🔧 I want utility scripts

Production-tested scripts for infrastructure management:
- **claude-provider** - Switch between Anthropic and Z.AI providers with automatic backups

**👉 [Scripts Guide: scripts/README.md](scripts/README.md)**

### 🌐 I want browser automation

Let Claude Code control a browser to test your app, review MRs, and automate workflows.

**What you need:**
1. Node.js with `npx` available
2. Chrome installed
3. 2 minutes

**👉 [Browser Automation Setup](#browser-automation-playwright-cli)**

---

## What Makes This Different?

### The Auto-Activation Breakthrough

**Problem:** Claude Code skills just sit there. You have to remember to use them.

**Solution:** UserPromptSubmit hook that:
- Analyzes your prompts
- Checks file context
- Automatically suggests relevant skills
- Works via `skill-rules.json` configuration

**Result:** Skills activate when you need them, not when you remember them.

### Two-Tier Code Review Strategy

**Problem:** Code reviews either don't happen (too manual) or are too heavy for every commit.

**Solution:** Two-tier review system enforced via `code-review-local` skill (`warn` enforcement):

| Tier | Tool | When | Speed |
|------|------|------|-------|
| **Per-commit** | `code-architecture-reviewer` Task agent | Every commit | ~30-60 seconds |
| **Milestone** | `code-review-local` skill (7 parallel agents) | Phase completions, pre-deploy | ~3-5 minutes |

The `code-review-local` skill is configured with `enforcement: "warn"` and `priority: "critical"`, so it actively warns whenever commit-related keywords appear. The warn message guides which tier to use.

### Production-Tested Patterns

These aren't theoretical examples - they're extracted from:
- ✅ 6 microservices in production
- ✅ 50,000+ lines of TypeScript
- ✅ React frontend with complex data grids
- ✅ Sophisticated workflow engine
- ✅ 6 months of daily Claude Code use

The patterns work because they solved real problems.

### Modular Skills (500-Line Rule)

Large skills hit context limits. The solution:

```
skill-name/
  SKILL.md                  # <500 lines, high-level guide
  resources/
    topic-1.md              # <500 lines each
    topic-2.md
    topic-3.md
```

**Progressive disclosure:** Claude loads main skill first, loads resources only when needed.

---

## Repository Structure

```
.claude/
├── skills/                 # 10 skills (some for user-level, some project-level)
│   ├── backend-dev-guidelines/  (12 resource files) [project-level]
│   ├── frontend-dev-guidelines/ (11 resource files) [project-level]
│   ├── playwright-cli/          (7 reference files) [user-level]
│   ├── skill-developer/         (7 resource files) [user-level]
│   ├── managing-dev-docs/       [user-level]
│   ├── route-tester/            [project-level]
│   ├── error-tracking/          [project-level]
│   └── skill-rules.json    # Project-level skill activation config
│
│   Note: User-level skills (skill-developer, managing-dev-docs, playwright-cli)
│   are in showcase as REFERENCE - users copy to ~/.claude/skills/
├── other-skills/           # Stack-specific skills (reference only)
│   ├── mixed-stack-guidelines/  [project-level]
│   └── php-backend-dev-guidelines/ [project-level]
├── hooks/                  # 6 hooks for automation
│   ├── skill-activation-prompt.*  (ESSENTIAL)
│   ├── post-tool-use-tracker.sh   (ESSENTIAL)
│   ├── tsc-check.sh        (optional, needs customization)
│   └── trigger-build-resolver.sh  (optional)
├── agents/                 # 10 specialized agents
│   ├── code-architecture-reviewer.md
│   ├── refactor-planner.md
│   ├── frontend-error-fixer.md
│   └── ... 7 more
└── commands/               # 3 slash commands
    ├── dev-docs.md
    └── ...

scripts/                    # Utility scripts
└── claude-provider         # Provider switcher (Anthropic/Z.AI)

dev/
└── active/                 # Dev docs pattern examples
    └── public-infrastructure-repo/
```

---

## Component Catalog

### 🎨 Skills (9)

| Skill | Lines | Purpose | Best For | Location |
|-------|-------|---------|----------|----------|
| [**skill-developer**](.claude/skills/skill-developer/) | 426 | Creating and managing skills | Meta-development | User-level |
| [**managing-dev-docs**](.claude/skills/managing-dev-docs/) | ~200 | Track features across sessions | Feature tracking | User-level |
| [**code-review-local**](.claude/skills/code-review-local/) | ~210 | 7-agent code review pipeline | Pre-commit/milestone reviews | Project-level |
| [**backend-dev-guidelines**](.claude/skills/backend-dev-guidelines/) | 304 | Express/Prisma/Sentry patterns | Backend APIs | Project-level |
| [**frontend-dev-guidelines**](.claude/skills/frontend-dev-guidelines/) | 398 | React/MUI v7/TypeScript | React frontends | Project-level |
| [**route-tester**](.claude/skills/route-tester/) | 389 | Testing authenticated routes | API testing | Project-level |
| [**error-tracking**](.claude/skills/error-tracking/) | ~250 | Sentry integration | Error monitoring | Project-level |
| [**playwright-cli**](.claude/skills/playwright-cli/) | ~280 | Browser automation via Playwright | Testing, MR review | User-level |
| **dev-docs-update** | N/A | Triggers `/dev-docs-update` command reminder | Post-commit workflow | Slash command |

**All skills follow the modular pattern** - main file + resource files for progressive disclosure.

**⚠️ Important:** Skills marked "User-level" should be copied to `~/.claude/skills/` (available everywhere), not project `.claude/skills/`. The showcase includes them as reference for users to copy.

**👉 [How to integrate skills →](.claude/skills/README.md)**

### 🪝 Hooks (6)

| Hook | Type | Essential? | Customization |
|------|------|-----------|---------------|
| skill-activation-prompt | UserPromptSubmit | ✅ YES | ✅ None needed |
| post-tool-use-tracker | PostToolUse | ✅ YES | ✅ None needed |
| tsc-check | Stop | ⚠️ Optional | ⚠️ Heavy - monorepo only |
| trigger-build-resolver | Stop | ⚠️ Optional | ⚠️ Heavy - monorepo only |
| error-handling-reminder | Stop | ⚠️ Optional | ⚠️ Moderate |
| stop-build-check-enhanced | Stop | ⚠️ Optional | ⚠️ Moderate |

**Start with the two essential hooks** - they enable skill auto-activation and work out of the box.

**👉 [Hook setup guide →](.claude/hooks/README.md)**

### 🤖 Agents (10)

**Standalone - just copy and use!**

| Agent | Purpose |
|-------|---------|
| code-architecture-reviewer | Review code for architectural consistency |
| code-refactor-master | Plan and execute refactoring |
| documentation-architect | Generate comprehensive documentation |
| frontend-error-fixer | Debug frontend errors |
| plan-reviewer | Review development plans |
| refactor-planner | Create refactoring strategies |
| web-research-specialist | Research technical issues online |
| auth-route-tester | Test authenticated endpoints |
| auth-route-debugger | Debug auth issues |
| auto-error-resolver | Auto-fix TypeScript errors |

**👉 [How agents work →](.claude/agents/README.md)**

### 💬 Slash Commands (3)

| Command | Purpose |
|---------|---------|
| /dev-docs | Create structured dev documentation |
| /dev-docs-update | Update docs before context reset |
| /route-research-for-testing | Research route patterns for testing |

### 🔧 Utility Scripts (1)

| Script | Purpose |
|--------|---------|
| claude-provider | Switch between API providers (Anthropic/Z.AI) with automatic backups |

**Standalone - copy to ~/bin/ and use!**

**👉 [Scripts guide →](scripts/README.md)**

---

## Key Concepts

### Hooks + skill-rules.json = Auto-Activation

**The system:**
1. **skill-activation-prompt hook** runs on every user prompt
2. Checks **skill-rules.json** for trigger patterns
3. Suggests relevant skills automatically
4. Skills load only when needed

**⚠️ IMPORTANT**: skill-rules.json can be in TWO locations:
- **Project-level:** `.claude/skills/skill-rules.json` (project-specific skills)
- **User-level:** `~/.claude/skills/skill-rules.json` (global skills available everywhere)

Some skills work better at user-level (skill-developer, managing-dev-docs) since they're useful across all projects.

**This solves the #1 problem** with Claude Code skills: they don't activate on their own.

### Progressive Disclosure (500-Line Rule)

**Problem:** Large skills hit context limits

**Solution:** Modular structure
- Main SKILL.md <500 lines (overview + navigation)
- Resource files <500 lines each (deep dives)
- Claude loads incrementally as needed

**Example:** backend-dev-guidelines has 12 resource files covering routing, controllers, services, repositories, testing, etc.

### Dev Docs Pattern

**Problem:** Context resets lose project context

**Solution:** Three-file structure
- `[task]-plan.md` - Strategic plan
- `[task]-context.md` - Key decisions and files
- `[task]-tasks.md` - Checklist format

**Works with:** `/dev-docs` slash command to generate these automatically

---

## ⚠️ Important: What Won't Work As-Is

### settings.json
The included `settings.json` is an **example only**:
- Stop hooks reference specific monorepo structure
- Service names (blog-api, etc.) are examples
- MCP servers may not exist in your setup

**To use it:**
1. Extract ONLY UserPromptSubmit and PostToolUse hooks
2. Customize or skip Stop hooks
3. Update MCP server list for your setup

### Blog Domain Examples
Skills use generic blog examples (Post/Comment/User):
- These are **teaching examples**, not requirements
- Patterns work for any domain (e-commerce, SaaS, etc.)
- Adapt the patterns to your business logic

### Hook Directory Structures
Some hooks expect specific structures:
- `tsc-check.sh` expects service directories
- Customize based on YOUR project layout

---

## Integration Workflow

**Recommended approach:**

### Phase 1: Skill Activation (15 min)
1. Copy skill-activation-prompt hook
2. Copy post-tool-use-tracker hook
3. **⚠️ CRITICAL**: Copy skill-rules.json to `.claude/skills/` (NOT `.claude/`)
   - OR create user-level `~/.claude/skills/skill-rules.json` for global skills
4. Update settings.json
5. Install hook dependencies

### Phase 2: Add First Skill (10 min)
1. Pick ONE relevant skill
2. Copy skill directory (to project or user level as appropriate)
3. Create/update skill-rules.json (project or user level)
4. Customize path patterns (project-level skills only)

### Phase 3: Test & Iterate (5 min)
1. Edit a file - skill should activate
2. Ask a question - skill should be suggested
3. Add more skills as needed

### Phase 4: Optional Enhancements
- Add agents you find useful
- Add slash commands
- Customize Stop hooks (advanced)

---

## Browser Automation (Playwright CLI)

Claude Code can control a browser to test your app, review MRs, fill forms, take screenshots, and more — all through natural language.

### How It Works

The [Playwright CLI](https://github.com/microsoft/playwright-cli) is a command-line tool from Microsoft that integrates with Claude Code as a **skill**. It's more token-efficient than MCP-based browser tools because it doesn't load large tool schemas into context.

Claude runs commands like `playwright-cli goto`, `playwright-cli click e5`, `playwright-cli fill e3 "text"` via Bash, using element refs from accessibility snapshots.

### Setup

**Prerequisites:** Node.js with `npx`, Chrome installed

```bash
# From your project directory (or any directory)
npx @playwright/cli install --skills
```

This creates `.claude/skills/playwright-cli/` in the current directory. For global availability, move it to your user-level skills:

```bash
mv .claude/skills/playwright-cli ~/.claude/skills/playwright-cli
```

### Updating

Playwright CLI is an npm package — `npx` will pull the latest version automatically. If the skill files are updated by Microsoft, re-run the install:

```bash
npx @playwright/cli install --skills
# Then move to ~/.claude/skills/ if using user-level
```

### Usage Examples

**Testing an authenticated web app:**
```
You: "Open the dev site and test the edit form on the sheets page"
Claude: Opens browser, you log in, Claude saves auth state,
        navigates, edits fields, saves, verifies persistence
```

**Reviewing a coworker's MR:**
```
You: "Open Mike's dev site and check if the new dashboard widget renders correctly"
Claude: Opens browser, navigates to the feature, takes snapshots,
        reports what it finds
```

**Key commands Claude uses:**
- `playwright-cli open <url>` — Launch browser (use `--headed` to see it)
- `playwright-cli snapshot` — Get page structure with element refs
- `playwright-cli click <ref>` / `fill <ref> <text>` — Interact with elements
- `playwright-cli state-save auth.json` — Save login session for reuse
- `playwright-cli network` / `console` — Debug requests and errors
- `playwright-cli screenshot` — Capture visual state

### Browser Support

Supports **Chromium, Firefox, and WebKit**. Chrome is recommended for the smoothest experience. Brave may work (Chromium-based) but isn't officially supported.

---

## Other Skills (Stack-Specific)

The `.claude/other-skills/` directory contains skills that are specific to particular technology stacks. These are provided as **reference implementations** — adapt them to your own stack.

| Skill | Purpose | Stack |
|-------|---------|-------|
| [**mixed-stack-guidelines**](.claude/other-skills/mixed-stack-guidelines/) | Guidelines for projects mixing multiple backend/frontend technologies | Multi-language projects |
| [**php-backend-dev-guidelines**](.claude/other-skills/php-backend-dev-guidelines/) | PHP backend development patterns | PHP/MongoDB |

These are separated from the main skills catalog because they're tailored to specific workflows rather than being universally applicable.

---

## Getting Help

### For Users
**Issues with integration?**
1. Check [CLAUDE_INTEGRATION_GUIDE.md](CLAUDE_INTEGRATION_GUIDE.md)
2. Ask Claude: "Why isn't [skill] activating?"
3. Open an issue with your project structure

### For Claude Code
When helping users integrate:
1. **Read CLAUDE_INTEGRATION_GUIDE.md FIRST**
2. Ask about their project structure
3. Customize, don't blindly copy
4. Verify after integration

---

## What This Solves

### Before This Infrastructure

❌ Skills don't activate automatically
❌ Have to remember which skill to use
❌ Large skills hit context limits
❌ Context resets lose project knowledge
❌ No consistency across development
❌ Manual agent invocation every time

### After This Infrastructure

✅ Skills suggest themselves based on context
✅ Hooks trigger skills at the right time
✅ Modular skills stay under context limits
✅ Dev docs preserve knowledge across resets
✅ Consistent patterns via guardrails
✅ Agents streamline complex tasks

---

## Community

**Found this useful?**

- ⭐ Star this repo
- 🐛 Report issues or suggest improvements
- 💬 Share your own skills/hooks/agents
- 📝 Contribute examples from your domain

**Background:**
This infrastructure was detailed in a post I made to Reddit ["Claude Code is a Beast – Tips from 6 Months of Hardcore Use"](https://www.reddit.com/r/ClaudeAI/comments/1oivjvm/claude_code_is_a_beast_tips_from_6_months_of/). After hundreds of requests, this showcase was created to help the community implement these patterns.


---

## License

MIT License - Use freely in your projects, commercial or personal.

---

## Quick Links

- 📖 [Claude Integration Guide](CLAUDE_INTEGRATION_GUIDE.md) - For AI-assisted setup
- 🎨 [Skills Documentation](.claude/skills/README.md)
- 🪝 [Hooks Setup](.claude/hooks/README.md)
- 🤖 [Agents Guide](.claude/agents/README.md)
- 🔧 [Utility Scripts](scripts/README.md)
- 📝 [Dev Docs Pattern](dev/README.md)

**Start here:** Copy the two essential hooks, add one skill, and see the auto-activation magic happen.
