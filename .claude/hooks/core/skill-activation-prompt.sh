#!/bin/bash
set -e

# Use current directory if CLAUDE_PROJECT_DIR is not set
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$PROJECT_DIR"
cat | npx tsx .claude/hooks/skill-activation-prompt.ts
