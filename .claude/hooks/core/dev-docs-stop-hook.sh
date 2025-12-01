#!/bin/bash
# Dev Docs Stop Hook
# Reminds about dev docs updates or auto-updates when session work is done

set -e

# Read input from stdin
INPUT=$(cat)

# Extract session information
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null || echo "")
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null || echo "false")

# Prevent infinite loops - if hook already ran, exit
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
    exit 0
fi

# Get session cache directory
if [ -z "$CLAUDE_PROJECT_DIR" ]; then
    exit 0
fi

CACHE_DIR="$CLAUDE_PROJECT_DIR/.claude/.cache/sessions/$SESSION_ID"

# Check if any files were edited this session
if [ ! -f "$CACHE_DIR/edited-files.txt" ]; then
    exit 0
fi

# Count unique edited files (excluding markdown)
EDITED_COUNT=$(sort -u "$CACHE_DIR/edited-files.txt" | wc -l)
if [ "$EDITED_COUNT" -eq 0 ]; then
    exit 0
fi

# Get unique affected areas
AFFECTED_AREAS=$(sort -u "$CACHE_DIR/affected-areas.txt" 2>/dev/null | grep -v "unknown" | grep -v "claude-config" || echo "")

# Check for active dev docs in user home
# Priority 1: Check for branch-based dev docs
# Priority 2: Fall back to any dev docs for this project
PROJECT_NAME=$(basename "$CLAUDE_PROJECT_DIR")

# Try to get current branch name
cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || true
BRANCH_NAME=$(git branch --show-current 2>/dev/null || echo "")

ACTIVE_FEATURES=""
BRANCH_DOCS_EXIST=false

# First, check if dev docs exist for current branch
if [ -n "$BRANCH_NAME" ] && [ -d "$HOME/.claude/dev-docs/$PROJECT_NAME/$BRANCH_NAME" ]; then
    ACTIVE_FEATURES="$BRANCH_NAME"
    BRANCH_DOCS_EXIST=true
else
    # Fall back to listing all dev docs for this project
    DEV_DOCS_DIR="$HOME/.claude/dev-docs/$PROJECT_NAME"
    if [ -d "$DEV_DOCS_DIR" ]; then
        ACTIVE_FEATURES=$(find "$DEV_DOCS_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null || echo "")
    fi
fi

# Check for auto-update flag
AUTO_UPDATE_FLAG="$CLAUDE_PROJECT_DIR/.claude/dev-docs-auto-update"
AUTO_UPDATE_ENABLED=false

if [ -f "$AUTO_UPDATE_FLAG" ]; then
    AUTO_UPDATE_ENABLED=true
fi

# If auto-update is enabled and we have active dev docs, block and instruct Claude
if [ "$AUTO_UPDATE_ENABLED" = "true" ] && [ -n "$ACTIVE_FEATURES" ]; then
    # Build list of features
    FEATURE_LIST=$(echo "$ACTIVE_FEATURES" | head -5 | sed 's/^/  → /')

    # Build affected areas summary
    AREAS_SUMMARY=""
    if [ -n "$AFFECTED_AREAS" ]; then
        AREAS_SUMMARY=$(echo "$AFFECTED_AREAS" | sort | uniq -c | sort -rn | head -3 | awk '{print "  → " $2 " (" $1 " files)"}')
    fi

    # Output JSON to block stop and instruct Claude
    cat <<EOF
{
  "decision": "block",
  "reason": "Before finishing, please update the development documentation.

📝 Session Summary:
- Files modified: $EDITED_COUNT
${AREAS_SUMMARY:+- Areas affected:
$AREAS_SUMMARY}

Active dev docs detected:
$FEATURE_LIST

Please update the relevant dev docs in ~/.claude/dev-docs/$PROJECT_NAME/ with:
1. New files created or modified (add to context.md)
2. Tasks completed (mark in tasks.md with [x])
3. New discoveries or decisions (add to context.md)
4. Any blockers or next steps

Use the dev-docs-manager agent or update files directly."
}
EOF
    exit 0
fi

# Otherwise, show passive reminder
if [ -n "$ACTIVE_FEATURES" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📝 DEV DOCS UPDATE REMINDER"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Session changes detected:"
    echo "  → $EDITED_COUNT files modified"

    if [ -n "$AFFECTED_AREAS" ]; then
        echo ""
        echo "Affected areas:"
        echo "$AFFECTED_AREAS" | sort | uniq -c | sort -rn | head -5 | awk '{print "  → " $2 " (" $1 " files)"}'
    fi

    echo ""
    if [ "$BRANCH_DOCS_EXIST" = "true" ]; then
        echo "Active dev docs for current branch:"
        echo "  → $BRANCH_NAME"
        echo "  📁 ~/.claude/dev-docs/$PROJECT_NAME/$BRANCH_NAME/"
    else
        echo "Active dev docs found:"
        echo "$ACTIVE_FEATURES" | head -5 | sed 's/^/  → /'
    fi
    echo ""
    echo "💡 Consider running: /dev-docs-update"
    echo ""
    echo "💡 Enable auto-updates: touch .claude/dev-docs-auto-update"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

exit 0
