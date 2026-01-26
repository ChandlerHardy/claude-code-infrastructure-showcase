---
name: refactoring-patterns
description: Code quality and refactoring analysis. Use when reviewing code for duplication, code smells, refactoring opportunities, DRY violations, extraction candidates, and architectural improvements. Identifies duplicated logic, similar code blocks, and opportunities to extract shared classes or functions.
---

# Refactoring Patterns

## Purpose

Identify refactoring opportunities, code duplication, and quality improvements in code reviews.

## When to Use

- Code review reveals duplicated logic between files
- Similar code blocks exist in multiple locations
- Functions/classes doing multiple responsibilities
- Before merging features with new code
- When MR feedback mentions "duplicated code" or "extract to shared class"

## What to Check

### 1. Code Duplication (DRY Violations)

**Red Flags:**
- Same logic in multiple files (copy-paste)
- Similar functions with slight variations
- Duplicated validation/normalization logic
- Repeated data transformations

**Refactoring:**
- Extract to shared class/function
- Create utility/helper module
- Use inheritance or composition
- Consolidate into single source of truth

**Example Pattern:**
```php
// BAD: Duplicated in file1.php and file2.php
function normalizeTag($tag) {
    return trim(strtoupper($tag));
}
function checkDuplicates($existing, $new) { ... }

// GOOD: Extract to shared class
// phplib/local/TagValidator.php
class TagValidator {
    public static function normalizeTag($tag) { ... }
    public static function checkDuplicates(...) { ... }
}
```

### 2. Function/Class Responsibilities

**Red Flags:**
- Function does multiple unrelated things
- Class has mixed concerns
- Long functions (>50 lines)
- Deep nesting (>3 levels)

**Refactoring:**
- Extract methods
- Split into smaller functions
- Separate concerns
- Single Responsibility Principle

### 3. Extraction Candidates

**Look for:**
- Repeated validation logic → Validator class
- Repeated API calls → API client class
- Repeated data formatting → Formatter/Transformer class
- Repeated business rules → Service/Domain class

### 4. Code Smells

**Common Issues:**
- Magic numbers/strings (use constants)
- Long parameter lists (use objects)
- Feature envy (method uses another class more than its own)
- Data clumps (same group of data passed together)

### 5. Language-Specific Patterns

**PHP:**
- Static methods for stateless utilities
- Namespaces for organization
- Type hints for clarity
- PSR-12 coding standards

**TypeScript:**
- Interfaces for contracts
- Generics for reusability
- Enums for constants
- Utility types

**React:**
- Custom hooks for reusable logic
- Component composition
- Context for shared state
- Prop drilling avoidance

## Review Checklist

When reviewing code:

- [ ] Scan for duplicated logic across files
- [ ] Check for similar code blocks (>10 lines)
- [ ] Look for repeated validation/transformation
- [ ] Identify extraction candidates
- [ ] Note functions doing multiple things
- [ ] Check for magic values needing constants
- [ ] Verify single responsibility
- [ ] Check for proper error handling
- [ ] Look for missing type hints/interfaces

## How to Report

**Format:**
```markdown
## Refactoring Opportunities

### 1. Duplicated Logic: [Function/Method Name]

**Location:**
- File A: lines X-Y
- File B: lines M-N

**Issue:** Same logic duplicated in both files

**Recommendation:** Extract to shared class `[ClassName]` in `[location]`

**Impact:** Eliminates [X] lines of duplication, improves maintainability
```

## Integration with Code Review

This skill should be invoked DURING code review to:
1. Identify refactoring opportunities
2. Catch DRY violations before merge
3. Suggest architectural improvements
4. Maintain codebase quality

Use alongside:
- Language-specific skills (php-backend-dev-guidelines, frontend-dev-guidelines)
- Domain-specific patterns
- Project architecture guidelines

## Real-World Example

**Scenario:** Two files both validate animal IDs with identical logic

**Before:**
- `add_animals.php`: 100 lines of duplicate validation
- `check_duplicate_ids.php`: 100 lines of duplicate validation

**Issue:** Code duplication, maintenance burden, potential divergence

**Refactoring:**
- Extract to `phplib/local/AnimalIdValidator.php`
- Both files use shared class
- Single source of truth
- Easier to test and maintain

**Result:**
- Eliminated 150+ lines of duplication
- Improved testability
- Clearer separation of concerns
- Easier to extend validation logic

---

**Status**: ACTIVE
**Line Count**: < 200 (following 500-line rule) ✅
