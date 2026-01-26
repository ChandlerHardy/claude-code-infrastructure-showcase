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

## Contributing Scripts

Have a useful script for Claude Code infrastructure? Contributions welcome!

**Criteria:**
- ✅ Production-tested
- ✅ Well-documented
- ✅ Portable (works on FreeBSD/Linux/macOS)
- ✅ Handles errors gracefully
- ✅ Follows existing patterns

**Submit via:** Pull request with script + documentation
