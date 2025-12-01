#!/bin/bash
# Dev Docs Branch Init Hook (SessionStart)
# Automatically detects current branch and initializes dev docs if needed

set -e

# Read input from stdin
INPUT=$(cat)

# Extract session information
SESSION_SOURCE=$(echo "$INPUT" | jq -r '.source // empty' 2>/dev/null || echo "")

# Only run on startup and resume (not on clear/compact)
if [ "$SESSION_SOURCE" != "startup" ] && [ "$SESSION_SOURCE" != "resume" ]; then
    exit 0
fi

# Check if we're in a git repository
if [ -z "$CLAUDE_PROJECT_DIR" ]; then
    exit 0
fi

cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0

# Check if this is a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    exit 0
fi

# Get current branch name
BRANCH_NAME=$(git branch --show-current 2>/dev/null || echo "")
if [ -z "$BRANCH_NAME" ]; then
    exit 0
fi

# Skip common branches that don't need dev docs
SKIP_BRANCHES="master|main|develop|staging|production"
if echo "$BRANCH_NAME" | grep -qE "^($SKIP_BRANCHES)$"; then
    exit 0
fi

# Get project name (directory name)
PROJECT_NAME=$(basename "$CLAUDE_PROJECT_DIR")

# Check if dev docs directory exists for this branch
DEV_DOCS_DIR="$HOME/.claude/dev-docs/$PROJECT_NAME/$BRANCH_NAME"

# If dev docs already exist, show context summary
if [ -d "$DEV_DOCS_DIR" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📚 DEV DOCS DETECTED"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Branch: $BRANCH_NAME"
    echo "Dev Docs: ~/.claude/dev-docs/$PROJECT_NAME/$BRANCH_NAME/"
    echo ""

    # Show task summary if tasks.md exists
    if [ -f "$DEV_DOCS_DIR/tasks.md" ]; then
        TOTAL_TASKS=$(grep -c "^- \[" "$DEV_DOCS_DIR/tasks.md" 2>/dev/null || echo "0")
        COMPLETED_TASKS=$(grep -c "^- \[x\]" "$DEV_DOCS_DIR/tasks.md" 2>/dev/null || echo "0")
        PENDING_TASKS=$((TOTAL_TASKS - COMPLETED_TASKS))

        if [ "$TOTAL_TASKS" -gt 0 ]; then
            echo "Progress: $COMPLETED_TASKS/$TOTAL_TASKS tasks complete ($PENDING_TASKS pending)"
            echo ""
        fi
    fi

    echo "💡 Use dev-docs-manager agent to view full context"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
fi

# Dev docs don't exist - check if this is a feature branch
# Feature branches typically start with feature/, fix/, bugfix/, hotfix/, etc.
FEATURE_PATTERN="^(feature|fix|bugfix|hotfix|enhancement|refactor|chore|docs|test)/"
IS_FEATURE_BRANCH=false

if echo "$BRANCH_NAME" | grep -qE "$FEATURE_PATTERN"; then
    IS_FEATURE_BRANCH=true
fi

# If it's a feature branch, suggest creating dev docs
if [ "$IS_FEATURE_BRANCH" = "true" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📝 NEW FEATURE BRANCH DETECTED"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Branch: $BRANCH_NAME"
    echo "Project: $PROJECT_NAME"
    echo ""
    echo "No dev docs found for this branch."
    echo ""
    echo "💡 Consider creating dev docs to track:"
    echo "   - Implementation plan"
    echo "   - Key context and decisions"
    echo "   - Task checklist"
    echo ""
    echo "To create dev docs, say:"
    echo "  'Create dev docs for this branch'"
    echo ""
    echo "Or use the dev-docs-manager agent directly."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

exit 0
