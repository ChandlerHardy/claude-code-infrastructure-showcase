---
name: code-review-local
description: Primary code review skill — use this instead of requesting-code-review. Enhanced 8-agent review with CRUD parity checking, refactoring analysis, and domain best practices on top of the standard 5-agent marketplace review. Triggers on code review requests, merge preparation, feature completion, and MR/PR prep. Dispatches code-reviewer agent to review implementation against plan or requirements.
---

**This skill automatically dispatches the code-reviewer agent when invoked.**
**This skill REPLACES requesting-code-review for all local projects.**

# Code Review Request

This skill will dispatch the code-reviewer agent to review your code changes.

## What the Agent Does

The code-reviewer agent examines:
1. **Code Quality**: Separation of concerns, error handling, DRY, edge cases
2. **Architecture**: Design decisions, scalability, performance, security
3. **Testing**: Coverage, edge cases, integration tests
4. **Requirements**: All specs met, no scope creep
5. **Production Readiness**: Migration strategy, backward compatibility, documentation
6. **Refactoring Opportunities**: Code duplication, DRY violations, extraction candidates (via refactoring-patterns skill)
7. **Domain-Specific Best Practices**: Language/framework patterns (via php-backend-dev-guidelines, frontend-dev-guidelines, etc.)
8. **CRUD Path Parity**: Verifies all sibling code paths (create/read/update/delete) were updated consistently when one path changes

## Review Process

When invoked, this skill will:
1. **Identify relevant domain skills** - Determine which language/framework-specific skills apply (PHP, React, TypeScript, etc.)
2. **Invoke domain skills** - Use Skill tool to load php-backend-dev-guidelines, refactoring-patterns, etc.
3. **Dispatch the code-reviewer agent** - Launch agent with domain knowledge loaded
4. **Provide structured feedback** - Severity levels (Critical, Important, Minor)
5. **Include refactoring suggestions** - Code duplication, extraction opportunities, DRY violations
6. **Domain-specific checks** - Language/framework best practices
7. **Help fix issues** - Guide implementation before proceeding

### Enhanced Review Agents

The review now includes **8 parallel agents** (instead of 5):

**Original Agents (from marketplace):**
1. CLAUDE.md compliance
2. Obvious bugs
3. Git history context
4. Previous PR comments
5. Code comment compliance

**NEW Agents:**
6. **Refactoring analysis** - Code duplication, DRY violations, extraction candidates
7. **Domain best practices** - Language/framework-specific patterns (PHP, TypeScript, React, etc.)
8. **CRUD path parity** - Verifies sibling code paths (create/read/update/delete) are updated consistently

## Usage

Simply use this skill when you need a code review. The agent will ask for context if needed.

Example triggers:
- After completing a feature implementation
- Before merging to main branch
- When addressing MR/PR feedback
- After fixing critical bugs

---

## Implementation Instructions for Code Review

When this skill is invoked, follow these steps:

### Step 1: Load Domain Skills

**BEFORE dispatching the code-reviewer agent**, identify and invoke relevant domain skills using a three-tier resolution:

**Step 1A: Project-level skills (PREFERRED)**
1. Check for `.claude/skills/` in the project root
2. Look for `*-guidelines/SKILL.md` files (e.g., `triagebox-guidelines`, `myapp-guidelines`)
3. If found, invoke these via the Skill tool — they contain patterns specific to THIS codebase
4. Project-level skills REPLACE generic domain skills (do NOT also load generic ones)

**Step 1B: Fallback to generic skills (only if NO project-level guidelines skill exists)**
```
.php files → php-backend-dev-guidelines
.ts/.tsx files → backend-dev-guidelines (if backend/) OR frontend-dev-guidelines (if frontend/)
.js/.jsx/.vue files → frontend-dev-guidelines
```

**Step 1C: Always invoke (regardless of project vs generic)**
- `refactoring-patterns` - Check for code duplication regardless of file type

**Example with project skill:**
```
User: "Run code review on my PR" (in triagebox project)
Assistant:
1. Checks .claude/skills/ → finds triagebox-guidelines/SKILL.md
2. Invokes: Skill tool with "triagebox-guidelines"
3. Invokes: Skill tool with "refactoring-patterns"
4. Does NOT invoke generic backend-dev-guidelines or frontend-dev-guidelines
5. Dispatches code-reviewer agent with project-specific context loaded
```

**Example without project skill:**
```
User: "Run code review on my PR" (in project without .claude/skills/*-guidelines/)
Assistant:
1. Checks .claude/skills/ → no *-guidelines found
2. Falls back: Invokes "php-backend-dev-guidelines" (for .php files)
3. Invokes: Skill tool with "refactoring-patterns"
4. Dispatches code-reviewer agent
```

### Step 2: Enhanced Review Agents

When dispatching the code-reviewer agent, include **8 parallel agents**:

**Agents 1-5** (from original marketplace skill):
1. CLAUDE.md compliance check
2. Obvious bugs (shallow scan)
3. Git history and blame analysis
4. Previous PR comments review
5. Code comment compliance

**NEW Agent 6: Refactoring Analysis**
```
Task: Using the refactoring-patterns skill loaded earlier, identify:
- Duplicated code between files (copy-paste)
- Similar logic with slight variations
- Extraction candidates (shared classes/functions)
- DRY violations
- Single Responsibility violations

Focus on:
- Functions/logic duplicated in 2+ files
- Code that could be consolidated
- Repeated validation/transformation logic

Report format:
- Location of duplication (file:lines)
- Recommendation (extract to X class/function)
- Impact (reduces Y lines, improves maintainability)
```

**NEW Agent 7: Domain Best Practices**
```
Task: Using the PROJECT-LEVEL guidelines skill (preferred) or generic domain
skills loaded in Step 1, check language/framework-specific patterns:
- Project-specific conventions (auth middleware, error helpers, DB access patterns)
- Framework conventions (Fastify plugins, Next.js App Router, React patterns, etc.)
- Error handling patterns (project's error helpers vs. raw throws)
- Security best practices
- Validation patterns (Zod schemas, shared types)
- API design patterns (response envelope, endpoint naming)

Focus on:
- Deviations from THIS PROJECT's established patterns (not generic best practices)
- Missing error handling using project's error helpers
- Security vulnerabilities
- Inconsistent use of auth guards/middleware

Report format:
- Issue description
- Which project pattern/guideline is violated
- Code location
- Recommended fix matching project conventions
```

**NEW Agent 8: CRUD Path Parity**
```
Task: For each data entity modified in the diff, verify all sibling code paths
were updated consistently.

Step 1 — Identify entities:
- What data collections/tables/models are being written to or read from in the diff?
- Example: if the diff writes to `group_packer_info`, that's the entity.

Step 2 — Map all code paths for each entity:
- CREATE path: form submission handlers, `newFromData()`, `insert()`, POST handlers
- READ path: `getData()`, `getAll*()`, list endpoints, export functions
- UPDATE path: `updateData()`, `edit()`, PATCH/PUT handlers
- DELETE path: `removeData()`, `delete()`, cleanup logic
- Look in the same class/file AND in related files (e.g., save_*.php calls Class::newFromData())

Step 3 — Check parity:
- If the diff adds/modifies writes to entity X in the UPDATE path, does the CREATE path
  also write to entity X? If not, flag it.
- If the diff changes how entity X is read in getData(), does getAll*() and export
  also read it the same way? If not, flag it.
- If the diff adds validation for entity X fields in edit, does create also validate them?
- If the diff adds cleanup/delete logic for entity X in one path, is it also handled
  in the delete path?

Step 4 — Check test coverage:
- For each code path that touches the entity, is there a corresponding test task
  in dev docs (tasks.md) or test file?
- Flag any untested code path.

Report format:
- Entity name
- Which paths were modified vs which were NOT
- Specific file:function for each missing path
- Risk: what breaks if this path is missed (e.g., "form submission won't create packer info")

Scoring:
- 90-100: A mutation path (create/update/delete) is missing — data loss or inconsistency
- 75-89: A read path is stale — displays wrong data
- 50-74: Validation or cleanup inconsistency — edge case bugs
- <50: Minor inconsistency unlikely to cause issues
```

**Real-world example (kill-sheet bug):**
The diff added `group_packer_info` writes in `updateData()` (edit path) but
`newFromData()` (create path) had no packer info logic. Agent 8 would flag:
- Entity: `group_packer_info`
- UPDATE path: modified (writes packer info) ✓
- CREATE path: NOT modified (no packer info writes) ✗
- Risk: "Sell form submission won't create packer info records — data only appears after sheet edit"
- Score: 95 (mutation path missing)

### Step 3: Scoring

Use the same 0-100 confidence scoring for ALL agents (including new ones):
- 0: False positive
- 25: Might be real, unverified
- 50: Real but minor
- 75: Highly confident, important
- 100: Absolutely certain

**For refactoring issues:**
- Score 75-100 if duplication is >20 lines or in 3+ files
- Score 50-75 if duplication is 10-20 lines or in 2 files
- Score <50 if duplication is <10 lines

**For domain best practice issues:**
- Score 75-100 if security issue or causes bugs
- Score 50-75 if maintainability/clarity issue
- Score <50 if stylistic preference

**For CRUD parity issues:**
- Score 90-100 if a mutation path (create/update/delete) is missing — data loss or inconsistency
- Score 75-89 if a read path is stale — displays wrong/outdated data
- Score 50-74 if validation or cleanup inconsistency — edge case bugs
- Score <50 if minor inconsistency unlikely to cause issues

### Step 4: Final Comment

Include ALL issues (from all 8 agents) that score 80+.

**Format:**
```markdown
### Code review

Found X issues:

1. **[Refactoring]** Duplicated logic: `checkForDuplicates()` (refactoring-patterns)
   - Files: add_animals.php:57-150, check_duplicate_ids.php:60-175
   - Recommendation: Extract to shared AnimalIdValidator class
   - Impact: Reduces 150+ lines of duplication

   [link to file:lines]

2. **[PHP Best Practice]** Missing error handling in createAnimal() (php-backend-dev-guidelines)
   - Should wrap API calls in try-catch
   - [link to file:lines]

3. **[Bug]** Variable $result not checked before use (shallow scan)
   - [link to file:lines]

🤖 Generated with [Claude Code](https://claude.ai/code)
```

---

## Real-World Example

**Scenario:** Reviewing the duplicate animal ID fix

**What happened in original review:**
- 5 agents checked: CLAUDE.md ✓, bugs ✓, history ✓, comments ✓, PR feedback ✓
- Result: "No issues found"

**What SHOULD have happened with enhanced review:**
1. Load php-backend-dev-guidelines (detected .php files)
2. Load refactoring-patterns (always load)
3. Launch 8 agents including:
   - **Agent 6**: Identifies 150+ lines duplicated between add_animals.php and check_duplicate_ids.php
   - **Agent 7**: Notes same validation logic in both files violates DRY
4. Score duplication as 85 (>20 lines, 2 files, clear extraction candidate)
5. Report: "Extract duplicate validation logic to shared AnimalIdValidator class"

**Result:** Would have caught the refactoring opportunity BEFORE reviewer pointed it out

### Real-World Example: Kill Sheet CRUD Parity Bug

**Scenario:** Reviewing the kill-sheet-phase-1 MR (packer info on sold events)

**What happened:**
- Agents 1-7 checked code quality, refactoring, domain practices — no issues
- MR pushed, Le Yang's review found hot_weight/base_price passed but not handled

**What Agent 8 would have caught:**
1. Entity identified: `group_packer_info`
2. Path mapping:
   - UPDATE: `Head_sold::updateData()` — writes to group_packer_info ✓
   - CREATE: `Head_sold::newFromData()` — NO packer info writes ✗
   - DELETE: `Head_sold::removeData()` — cleans up orphaned records ✓
   - READ: `Head_sold::getData()` — reads from group_packer_info ✓
   - READ: `Head_sold::getAllHeadSoldForGroups()` — reads stale fields from events ✗
3. Score: 95 (mutation path missing — form submissions won't create packer info)
4. Report: "CREATE path missing: `newFromData()` doesn't write to `group_packer_info`. Users who sell via the form won't get packer info records — only edits on sheets will work."

**Result:** Would have caught the bug before MR review