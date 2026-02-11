---
name: code-review-local
description: FreeBSD-compatible code review workflow. Use when completing tasks, implementing major features, or before merging to verify work meets requirements. Triggers on code review requests, merge preparation, and feature completion. Dispatches code-reviewer agent to review implementation against plan or requirements before proceeding.

**This skill automatically dispatches the code-reviewer agent when invoked.**
---

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

The review now includes **7 parallel agents** (instead of 5):

**Original Agents (from marketplace):**
1. CLAUDE.md compliance
2. Obvious bugs
3. Git history context
4. Previous PR comments
5. Code comment compliance

**NEW Agents:**
6. **Refactoring analysis** - Code duplication, DRY violations, extraction candidates
7. **Domain best practices** - Language/framework-specific patterns (PHP, TypeScript, React, etc.)

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

**BEFORE dispatching the code-reviewer agent**, identify and invoke relevant domain skills:

**File type detection:**
```
.php files → php-backend-dev-guidelines
.ts/.tsx files → backend-dev-guidelines (if backend/) OR frontend-dev-guidelines (if frontend/)
.js/.jsx/.vue files → frontend-dev-guidelines
ANY files with potential duplication → refactoring-patterns
```

**Always invoke:**
- `refactoring-patterns` - Check for code duplication regardless of file type

**Language-specific:**
- `php-backend-dev-guidelines` - For PHP files
- `frontend-dev-guidelines` - For frontend JavaScript/TypeScript
- `backend-dev-guidelines` - For backend Node.js/TypeScript

**Example:**
```
User: "Run code review on my PR"
Assistant:
1. Checks PR files: add_animals.php, check_duplicate_ids.php, AnimalIdValidator.php
2. Invokes: Skill tool with "php-backend-dev-guidelines"
3. Invokes: Skill tool with "refactoring-patterns"
4. THEN dispatches code-reviewer agent with context loaded
```

### Step 2: Enhanced Review Agents

When dispatching the code-reviewer agent, include **7 parallel agents**:

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
Task: Using domain skills loaded earlier (php-backend-dev-guidelines, etc.), check:
- Language-specific patterns (PHP static methods, TypeScript interfaces, etc.)
- Framework conventions (PSR-12 for PHP, React patterns, etc.)
- Error handling patterns
- Security best practices
- Validation patterns
- API design patterns

Focus on:
- Deviations from established patterns
- Missing error handling
- Security vulnerabilities
- Poor separation of concerns

Report format:
- Issue description
- Which guideline violated
- Code location
- Recommended fix
```

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

### Step 4: Final Comment

Include ALL issues (from all 7 agents) that score 80+.

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
3. Launch 7 agents including:
   - **Agent 6**: Identifies 150+ lines duplicated between add_animals.php and check_duplicate_ids.php
   - **Agent 7**: Notes same validation logic in both files violates DRY
4. Score duplication as 85 (>20 lines, 2 files, clear extraction candidate)
5. Report: "Extract duplicate validation logic to shared AnimalIdValidator class"

**Result:** Would have caught the refactoring opportunity BEFORE reviewer pointed it out