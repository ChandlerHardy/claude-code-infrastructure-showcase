#!/usr/bin/env bash
#
# Install recommended community skills for Claude Code.
# Downloads standalone skills (not managed by superpowers marketplace)
# to ~/.claude/skills/ (user-level) or .claude/skills/ (project-level).
#
# Usage:
#   ./scripts/install-recommended-skills.sh              # Install all recommended
#   ./scripts/install-recommended-skills.sh --list        # List available skills
#   ./scripts/install-recommended-skills.sh --skill NAME  # Install specific skill
#   ./scripts/install-recommended-skills.sh --project     # Install to project-level
#   ./scripts/install-recommended-skills.sh --dry-run     # Show what would be installed

set -euo pipefail

# ─── Configuration ──────────────────────────────────────────────────────────────

# Where to install skills (default: user-level)
INSTALL_DIR="${HOME}/.claude/skills"
DRY_RUN=false
SPECIFIC_SKILL=""

# Skill registry: name|repo|path_in_repo|description
# Add new skills here — one per line
SKILLS=(
  "test-driven-development|obra/superpowers|skills/test-driven-development|Enforces write-test-first workflow with red/green/refactor"
  "systematic-debugging|obra/superpowers|skills/systematic-debugging|Structured root-cause analysis with hypothesis tracking"
  "dispatching-parallel-agents|obra/superpowers|skills/dispatching-parallel-agents|Teaches Claude when/how to parallelize Task agents"
  "verification-before-completion|obra/superpowers|skills/verification-before-completion|Prevents Claude from claiming done without verifying"
  "subagent-driven-development|obra/superpowers|skills/subagent-driven-development|Patterns for effective work delegation to subagents"
  "using-git-worktrees|obra/superpowers|skills/using-git-worktrees|Parallel branch work without stashing"
)

# ─── Argument Parsing ───────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case $1 in
    --project)
      INSTALL_DIR=".claude/skills"
      shift
      ;;
    --list)
      echo "Available recommended skills:"
      echo ""
      printf "  %-35s %s\n" "SKILL" "DESCRIPTION"
      printf "  %-35s %s\n" "─────" "───────────"
      for entry in "${SKILLS[@]}"; do
        IFS='|' read -r name repo path desc <<< "$entry"
        printf "  %-35s %s\n" "$name" "$desc"
      done
      echo ""
      echo "Source repos:"
      printf "  %s\n" "obra/superpowers"
      exit 0
      ;;
    --skill)
      SPECIFIC_SKILL="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --list          List available skills"
      echo "  --skill NAME    Install a specific skill only"
      echo "  --project       Install to .claude/skills/ (project-level)"
      echo "  --dry-run       Show what would be installed without installing"
      echo "  --help          Show this help"
      echo ""
      echo "Default: installs all recommended skills to ~/.claude/skills/"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Run '$0 --help' for usage"
      exit 1
      ;;
  esac
done

# ─── Dependencies ───────────────────────────────────────────────────────────────

if ! command -v gh &> /dev/null; then
  echo "Error: 'gh' (GitHub CLI) is required but not installed."
  echo "Install: https://cli.github.com/"
  exit 1
fi

if ! gh auth status &> /dev/null 2>&1; then
  echo "Error: 'gh' is not authenticated. Run 'gh auth login' first."
  exit 1
fi

# ─── Functions ──────────────────────────────────────────────────────────────────

install_skill() {
  local name="$1"
  local repo="$2"
  local path="$3"
  local desc="$4"
  local target_dir="${INSTALL_DIR}/${name}"

  if [[ -d "$target_dir" ]]; then
    echo "  [skip] ${name} — already installed at ${target_dir}"
    return 0
  fi

  if [[ "$DRY_RUN" == true ]]; then
    echo "  [dry-run] Would install ${name} from ${repo}/${path} → ${target_dir}"
    return 0
  fi

  echo "  [install] ${name} — ${desc}"

  # Create target directory
  mkdir -p "$target_dir"

  # Download skill files using GitHub API
  local files
  files=$(gh api "repos/${repo}/contents/${path}" --jq '.[].name' 2>/dev/null || echo "")

  if [[ -z "$files" ]]; then
    # Maybe it's a single file (SKILL.md), try the path directly
    local single_file
    single_file=$(gh api "repos/${repo}/contents/${path}/SKILL.md" --jq '.content' 2>/dev/null || echo "")
    if [[ -n "$single_file" ]]; then
      echo "$single_file" | base64 -d > "${target_dir}/SKILL.md"
      echo "    → ${target_dir}/SKILL.md"
    else
      echo "  [error] Could not find skill files at ${repo}/${path}"
      rm -rf "$target_dir"
      return 1
    fi
    return 0
  fi

  # Download each file
  for file in $files; do
    local content
    local file_type
    file_type=$(gh api "repos/${repo}/contents/${path}/${file}" --jq '.type' 2>/dev/null || echo "file")

    if [[ "$file_type" == "dir" ]]; then
      # Recursively download subdirectory
      mkdir -p "${target_dir}/${file}"
      local subfiles
      subfiles=$(gh api "repos/${repo}/contents/${path}/${file}" --jq '.[].name' 2>/dev/null || echo "")
      for subfile in $subfiles; do
        content=$(gh api "repos/${repo}/contents/${path}/${file}/${subfile}" --jq '.content' 2>/dev/null || echo "")
        if [[ -n "$content" ]]; then
          echo "$content" | base64 -d > "${target_dir}/${file}/${subfile}"
          echo "    → ${target_dir}/${file}/${subfile}"
        fi
      done
    else
      content=$(gh api "repos/${repo}/contents/${path}/${file}" --jq '.content' 2>/dev/null || echo "")
      if [[ -n "$content" ]]; then
        echo "$content" | base64 -d > "${target_dir}/${file}"
        echo "    → ${target_dir}/${file}"
      fi
    fi
  done
}

# ─── Main ───────────────────────────────────────────────────────────────────────

echo ""
echo "Claude Code Skill Installer"
echo "Target: ${INSTALL_DIR}"
echo ""

mkdir -p "$INSTALL_DIR"

installed=0
skipped=0
errors=0

for entry in "${SKILLS[@]}"; do
  IFS='|' read -r name repo path desc <<< "$entry"

  # Filter if specific skill requested
  if [[ -n "$SPECIFIC_SKILL" && "$name" != "$SPECIFIC_SKILL" ]]; then
    continue
  fi

  if install_skill "$name" "$repo" "$path" "$desc"; then
    ((installed++))
  else
    ((errors++))
  fi
done

echo ""
if [[ "$DRY_RUN" == true ]]; then
  echo "Dry run complete. No files were modified."
else
  echo "Done. Installed: ${installed}, Skipped (existing): ${skipped}, Errors: ${errors}"
  echo ""
  echo "Note: If you use the superpowers marketplace, these skills may"
  echo "already be available. Check with: /plugin list"
fi
