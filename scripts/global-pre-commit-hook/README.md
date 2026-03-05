# Global Pre-Commit Security Hook

A lightweight secret-scanning git hook that installs globally and applies to every repo on your machine automatically.

No dependencies. No services. Just a shell script that runs before every commit.

---

## What It Catches

| Pattern | Example |
|---------|---------|
| OpenAI / Anthropic keys | `sk-proj-abc123...` |
| GitHub personal access tokens | `ghp_abc123...` |
| GitHub OAuth tokens | `gho_abc123...` |
| GitLab personal access tokens | `glpat-abc123...` |
| Generic `api_key = "value"` | `api_key = "longvalue..."` |

Markdown files are skipped — docs often contain example key patterns that would false-positive.

---

## Install

### 1. Set up the global template directory

```bash
mkdir -p ~/.git-template/hooks
cp pre-commit ~/.git-template/hooks/pre-commit
chmod +x ~/.git-template/hooks/pre-commit
git config --global init.templateDir ~/.git-template
```

New repos will inherit the hook automatically via `git init` or `git clone`.

### 2. Apply to existing repos

```bash
# Single repo
cp ~/.git-template/hooks/pre-commit /path/to/repo/.git/hooks/pre-commit

# All repos under ~/repos at once
find ~/repos -name ".git" -maxdepth 2 -type d | while read d; do
  cp ~/.git-template/hooks/pre-commit "$d/hooks/pre-commit"
  echo "Installed: $d"
done
```

---

## Usage

Nothing to do — it runs automatically on every `git commit`. You'll see:

```
🔒 Running security scan...
✅ Security scan passed - no secrets detected
```

Or if a secret is found:

```
🔒 Running security scan...
❌ Potential secret found in: src/config.ts (sk- key pattern)

❌ SECURITY SCAN FAILED: Secrets detected in staged files.
   Remove sensitive data before committing.
   To bypass (dangerous): git commit --no-verify
```

---

## Bypass

```bash
git commit --no-verify -m "message"
```

Only use this when you've confirmed the match is a false positive (e.g., a test fixture with a fake key). Never use it to commit real credentials.

---

## Extending

Add patterns to the hook script as needed:

```bash
# AWS keys
if echo "$CONTENT" | grep -iE "AKIA[A-Z0-9]{16}" > /dev/null 2>&1; then
    echo "❌ Potential secret found in: $file (AWS access key)"
    SECRETS_FOUND=1
fi

# Slack tokens
if echo "$CONTENT" | grep -iE "xox[baprs]-[a-zA-Z0-9-]+" > /dev/null 2>&1; then
    echo "❌ Potential secret found in: $file (Slack token)"
    SECRETS_FOUND=1
fi
```

---

## Why Not Just Use TruffleHog / Gitleaks?

Those are great for CI scanning. This hook is for local prevention — catching secrets before they ever leave your machine. They complement each other.

This hook is intentionally simple: no config files, no dependencies, no setup beyond copying a script. If it runs slow on large repos, you can scope it to specific file extensions.
