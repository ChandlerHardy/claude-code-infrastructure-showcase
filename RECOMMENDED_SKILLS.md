# Recommended Community Skills

Skills and plugins from the community that complement this showcase's infrastructure. These are **not bundled** — install them separately to stay up to date with their maintainers.

---

## Superpowers (obra/superpowers)

The most comprehensive Claude Code skill collection. Install via the marketplace:

```bash
# In Claude Code:
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

### Recommended Skills

| Skill | What It Does | Why You Need It |
|-------|-------------|-----------------|
| **test-driven-development** | Enforces write-test-first workflow with red/green/refactor cycle | Prevents "I'll add tests later" drift — catches bugs before they ship |
| **systematic-debugging** | Structured root-cause analysis with hypothesis tracking | Stops shotgun debugging — methodical instead of random |
| **dispatching-parallel-agents** | Teaches Claude when/how to parallelize work across Task agents | Dramatically speeds up multi-file changes and research |
| **verification-before-completion** | Prevents Claude from claiming "done" without verifying | Complements the code-review-local Stop hook in this showcase |
| **subagent-driven-development** | Patterns for effective work delegation to subagents | Better quality from Task agents with clear contracts |
| **using-git-worktrees** | Parallel branch work without stashing/switching | Nice-to-have for concurrent feature development |

### Other Notable Superpowers Skills

| Skill | What It Does |
|-------|-------------|
| **brainstorming** | Structured ideation with divergent/convergent phases |
| **writing-plans** | Plan creation with scope management |
| **writing-skills** | Meta-skill for creating new skills (similar to our skill-developer) |
| **ultrathink** | Extended reasoning for complex architectural decisions |

---

## Quick Install Script

For skills **not** managed by the superpowers marketplace (standalone community skills), use the install script:

```bash
# Install recommended standalone skills
./scripts/install-recommended-skills.sh

# Install specific skill(s)
./scripts/install-recommended-skills.sh --skill owasp-security

# List available skills without installing
./scripts/install-recommended-skills.sh --list

# Install to project-level instead of user-level
./scripts/install-recommended-skills.sh --project
```

---

## How This Relates to the Showcase

```
┌─────────────────────────────────────────────────┐
│ This Showcase (bundled)                         │
│  - Skill activation hooks (UserPromptSubmit)    │
│  - skill-rules.json (trigger configuration)     │
│  - Domain skills (frontend, backend, etc.)      │
│  - Plugins (hookify, feature-dev, ralph-loop)   │
│  - Agents (code-review, refactoring, etc.)      │
├─────────────────────────────────────────────────┤
│ Superpowers (install separately)                │
│  - Process skills (TDD, debugging, planning)    │
│  - Agent orchestration (parallel, subagent)     │
│  - Quality gates (verification)                 │
├─────────────────────────────────────────────────┤
│ Standalone Skills (install separately)          │
│  - Security (OWASP patterns)                    │
│  - Accessibility (a11y checks)                  │
│  - DevOps (CI/CD, Docker patterns)              │
└─────────────────────────────────────────────────┘
```

**The showcase handles *when* skills activate. Community skills handle *what* those skills teach.**

---

## Contributing

Know a great Claude Code skill or plugin? Open an issue or PR to add it to this list.

**Criteria for inclusion:**
- Actively maintained
- Solves a real problem (not a toy example)
- Doesn't duplicate showcase functionality
- Works with Claude Code v2.1+
