# Utility Scripts

Production-tested scripts for Claude Code infrastructure management.

---

## claude-provider

**Portable Claude Code provider switcher** - seamlessly switch between Anthropic and alternative API providers.

### What It Does

Manages Claude Code API provider configuration with automatic backups, supporting:
- **Anthropic** (official OAuth)
- **Z.AI** (cost-effective proxy with 3x usage multiplier)

### Features

- ✅ Automatic settings backup before each switch
- ✅ Provider-specific configuration management
- ✅ API key secure setup for proxy providers
- ✅ Restore from backup capability
- ✅ Current provider detection
- ✅ FreeBSD/Linux/macOS compatible

### Quick Start

#### Installation

```bash
# Copy to your local bin directory
cp scripts/claude-provider ~/bin/
chmod +x ~/bin/claude-provider

# Or create a symlink
ln -s $(pwd)/scripts/claude-provider ~/bin/claude-provider
```

Ensure `~/bin` is in your PATH.

#### Dependencies

```bash
# FreeBSD
pkg install jq

# macOS
brew install jq

# Linux
apt-get install jq  # Debian/Ubuntu
yum install jq      # RHEL/CentOS
```

### Usage

#### List available providers
```bash
claude-provider list
```

#### Show current provider configuration
```bash
claude-provider current
```

#### Setup Z.AI provider
```bash
claude-provider setup zai
# Prompts for API key with confirmation
```

#### Switch to a provider
```bash
# Switch to Anthropic (OAuth)
claude-provider use anthropic

# Switch to Z.AI (after setup)
claude-provider use zai
```

#### Manage backups
```bash
# List available backups
claude-provider backups

# Restore from backup
claude-provider restore settings_20240126_143022.json
```

### How It Works

The script manages two configuration files:

1. **`~/.claude/settings.json`** - Claude Code settings
   - Anthropic mode: Minimal config, uses OAuth
   - Z.AI mode: Custom `env` variables for proxy configuration

2. **`~/.claude-provider-config.yaml`** - Provider metadata
   - Tracks current provider
   - Stores API keys for proxy providers
   - Provider descriptions and settings

### Provider Details

#### Anthropic (Official)
- **Authentication**: OAuth (browser-based)
- **Models**: Default Claude models (Haiku, Sonnet, Opus)
- **Cost**: Standard Anthropic pricing
- **Configuration**: Minimal (removes custom env vars)

#### Z.AI (Cost-Effective Proxy)
- **Authentication**: API key
- **Models**:
  - GLM-4.5-air (Haiku equivalent)
  - GLM-4.7 (Sonnet/Opus equivalent)
- **Cost**: ~3x usage at lower cost
- **Configuration**: Custom base URL and model mappings
- **Timeout**: Extended to 3000000ms for long operations

### Configuration Files

#### settings.json (Anthropic)
```json
{}
```
Or with other unrelated settings, but no `env` block.

#### settings.json (Z.AI)
```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "your-zai-api-key",
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "API_TIMEOUT_MS": "3000000",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.5-air",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-4.7",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-4.7"
  }
}
```

#### .claude-provider-config.yaml
```yaml
# Claude Provider Configuration
current_provider: "anthropic"
providers:
  anthropic:
    type: "oauth"
    description: "Official Anthropic Claude Code (OAuth)"
  zai:
    type: "api_key"
    description: "Z.AI proxy (3x usage at lower cost)"
    api_key: "your-api-key-here"
    base_url: "https://api.z.ai/api/anthropic"
    timeout_ms: 3000000
```

### Safety Features

- **Automatic backups** before every provider switch
- **Backup naming**: `settings_YYYYMMDD_HHMMSS.json`
- **Backup location**: `~/.claude/backups/`
- **API key confirmation** during setup (prevents typos)
- **Non-empty validation** for API keys
- **Restore capability** from any backup

### Important Notes

1. **Restart required**: After switching providers, restart Claude Code for changes to take effect
2. **Setup before use**: Z.AI requires `setup zai` before first use
3. **API key security**: Keys stored in `~/.claude-provider-config.yaml` (user-only permissions)
4. **Model compatibility**: Z.AI uses different model names, mapped automatically

### Troubleshooting

#### "jq is required but not installed"
Install jq using your system package manager (see Dependencies above).

#### "Z.AI API key not configured"
Run `claude-provider setup zai` first, then `claude-provider use zai`.

#### Settings not taking effect
Restart Claude Code completely (exit and relaunch).

#### Backup restore not working
Check available backups with `claude-provider backups` and use the exact filename.

### Examples

**Typical workflow for Z.AI:**
```bash
# One-time setup
claude-provider setup zai
# Enter API key when prompted

# Switch to Z.AI
claude-provider use zai
# Restart Claude Code

# Later, switch back to Anthropic
claude-provider use anthropic
# Restart Claude Code
```

**Backup management:**
```bash
# Before major changes
claude-provider backups

# If something goes wrong
claude-provider restore settings_20240126_143022.json
```

### Related Files

- `.claude/settings.json` - Main Claude Code configuration
- `.claude-provider-config.yaml` - Provider configuration and API keys
- `.claude/backups/` - Automatic settings backups

---

## playwright-brave

**Playwright CLI wrapper for Brave browser extension mode** - connects to your existing Brave session with all cookies and login state.

### What It Does

Wraps `npx @playwright/cli` with automatic Brave browser configuration and profile-aware token selection. Extension mode connects to your running Brave instance — no separate browser window, no re-logging in.

### Features

- Connects to your existing Brave browser (extension mode)
- Auto-selects work/personal MCP extension token based on directory
- No separate browser profile or login needed
- All standard Playwright CLI commands pass through

### Prerequisites

1. **Brave browser** installed at `/Applications/Brave Browser.app/` (macOS)
2. **Playwright MCP Bridge** extension from the [Chrome Web Store](https://chromewebstore.google.com/detail/playwright-mcp-bridge/mmlmfjhmonkocbjadbfplnigmagldckm)
3. **Playwright CLI skill** installed: `npx @playwright/cli install --skills`
4. **Config file** at `~/.playwright-cli/brave.config.json`:

```json
{
  "browser": {
    "browserName": "chromium",
    "launchOptions": {
      "executablePath": "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser",
      "headless": false
    }
  }
}
```

### Installation

```bash
# Copy to your local bin directory
cp scripts/playwright-brave ~/bin/
chmod +x ~/bin/playwright-brave

# Edit the script to add your tokens (see Token Setup)
```

Ensure `~/bin` is in your PATH.

### Token Setup

Each Brave profile has a unique extension token:

1. Open Brave with your **work** profile
2. Click the Playwright MCP Bridge extension icon
3. Copy the `PLAYWRIGHT_MCP_EXTENSION_TOKEN` value
4. Edit `~/bin/playwright-brave` and set `WORK_TOKEN`
5. Repeat for your **personal** profile → set `PERSONAL_TOKEN`
6. Adjust `WORK_DIR_PATTERN` to match your work directory structure

### Usage

```bash
# Open extension mode (connects to existing Brave)
playwright-brave

# Navigate to a page
playwright-brave goto https://example.com

# Take a snapshot (get element refs for automation)
playwright-brave snapshot

# Click an element by ref
playwright-brave click e5

# Fill a form field
playwright-brave fill e12 "some text"

# Take a screenshot
playwright-brave screenshot

# Close the session
playwright-brave close
```

### How Token Auto-Detection Works

The script checks your current working directory:

| Directory Pattern | Token Used | Example |
|---|---|---|
| `*/repos/dev[0-4]/*` | Work token | `~/repos/dev1/pb-www/` |
| Everything else | Personal token | `~/repos/my-project/` |

Customize `WORK_DIR_PATTERN` in the script to match your setup.

### How It Differs From Standard Playwright CLI

| Standard CLI | playwright-brave |
|---|---|
| Launches new browser window | Connects to existing Brave |
| Fresh profile (no cookies) | Uses your logged-in session |
| Must log in every time | No login needed |
| Chrome only by default | Brave via config |
| Manual token management | Auto-selects work/personal token |

### Important Notes

1. **Brave must be running** with the extension installed before using extension mode
2. **CLI reports "chrome"** in output — this is normal, Brave is Chromium-based
3. **One session at a time** — close before opening a new one
4. **Token changes per profile** — if you switch Brave profiles, update the token
5. **Linux users** — update `executablePath` in the config to your Brave binary path

### Troubleshooting

#### "Extension connection timeout"
- Ensure Brave is open with the Playwright MCP Bridge extension installed
- Verify the token matches the current Brave profile
- Try clicking the extension icon in Brave to confirm it's active

#### Commands work but wrong Brave profile
- Check which Brave profile is active — the token must match
- Each profile has its own unique token

#### "command not found: npx"
- Ensure Node.js/npm is installed and in your PATH

---

## Contributing Scripts

Have a useful script for Claude Code infrastructure? Contributions welcome!

**Criteria:**
- ✅ Production-tested
- ✅ Well-documented
- ✅ Portable (works on FreeBSD/Linux/macOS)
- ✅ Handles errors gracefully
- ✅ Follows existing patterns

**Submit via:** Pull request with script + documentation
