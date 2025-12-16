# smart_env Quick Start Guide

Get started with smart_env's powerful environment management features in minutes!

## Installation

```fish
omf install smart_env
```

## Core Commands

| Command | Description |
|---------|-------------|
| `smart_env FILE...` | Load .env file(s) |
| `smart_env_switch [FILE]` | Switch between env contexts |
| `smart_env_load [OPTIONS] FILE...` | Load with options (--sticky, --replace) |
| `smart_env_list` | List all contexts and files |
| `smart_env_forget FILE` | Unload and forget a file |
| `smart_env_1password ITEM` | Load from 1Password |
| `smart_env_unset` | Manually unset current directory vars |
| `smart_env_reset` | Reset all approvals |

## Quick Examples

### Basic Loading
```fish
# Load a file
smart_env .env

# Load multiple files
smart_env .env .env.local
```

### Switch Between Environments
```fish
# Show available files
smart_env_switch

# Switch to different environment
smart_env_switch .env.demo
smart_env_switch .env.staging
smart_env_switch .env.production
```

### Sticky Environments (Persist Across Directories)
```fish
# Load and keep everywhere
smart_env_load --sticky .env.credentials

# These vars stay loaded even when you cd elsewhere!
```

### 1Password Integration
```fish
# Load secrets from 1Password
smart_env_1password my-secrets

# From specific vault
smart_env_1password --vault MyVault production-secrets

# Keep sticky across directories
smart_env_1password --sticky production-secrets

# Load only one field
smart_env_1password --field DATABASE_URL my-secrets
```

### Managing Contexts
```fish
# See what's loaded
smart_env_list

# Forget a file
smart_env_forget .env.old

# Forget 1Password context
smart_env_1password_forget production-secrets
```

## Common Patterns

### Pattern 1: Different environments per project
```fish
cd ~/project
smart_env_switch .env.development  # for dev work
smart_env_switch .env.staging      # for testing
smart_env_switch .env.production   # for prod checks
```

### Pattern 2: Shared credentials + project config
```fish
# Load shared creds once (sticky)
smart_env_load --sticky ~/.aws/.env.credentials

# Each project loads its own config
cd ~/project1 && smart_env .env
cd ~/project2 && smart_env .env
# AWS creds available in both!
```

### Pattern 3: Secrets from 1Password + local config
```fish
# Secrets from 1Password (sticky)
smart_env_1password --sticky production-secrets

# Local config from file
smart_env .env.local
```

## Options Reference

### smart_env_load options
- `-s, --sticky` - Keep loaded across directory changes
- `-r, --replace` - Replace current context
- `-h, --help` - Show help

### smart_env_1password options
- `-v, --vault VAULT` - Specify vault name
- `-f, --field FIELD` - Load only specific field
- `-n, --name NAME` - Custom context name
- `-s, --sticky` - Keep across directory changes
- `-h, --help` - Show help

## Security Features

✅ **Approval required** - First time loading any file requires approval  
✅ **Change detection** - Alerts you when file contents change  
✅ **Diff view** - See exactly what changed before loading  
✅ **No value display** - Variable values are never shown in output  
✅ **Automatic cleanup** - Variables unset when leaving directory  

## 1Password Setup

1. **Install CLI:**
   ```fish
   brew install 1password-cli
   ```

2. **Sign in:**
   ```fish
   op signin
   ```

3. **Create item in 1Password:**
   - Add fields for each environment variable
   - Field label = variable name (e.g., `DATABASE_URL`)
   - Field value = the secret value

4. **Load it:**
   ```fish
   smart_env_1password my-item-name
   ```

## Tips

💡 **Show current context:** Run `smart_env_switch` with no args  
💡 **List everything:** Run `smart_env_list`  
💡 **Sticky for credentials:** Use `--sticky` for API keys and secrets you need everywhere  
💡 **Switch for testing:** Use `smart_env_switch` to quickly test different configs  
💡 **Combine sources:** Mix 1Password secrets with file-based config  

## Workflow Example

```fish
# Morning routine
cd ~/projects/my-app
smart_env_1password --sticky aws-credentials    # Load AWS creds
smart_env_switch .env.development               # Switch to dev env

# Need to test staging
smart_env_switch .env.staging                   # AWS creds still loaded!

# Check prod
smart_env_switch .env.production
./health-check.sh

# Back to dev
smart_env_switch .env.development
```

## Getting Help

- **Full docs:** See [README.md](README.md)
- **Examples:** See [EXAMPLES.md](EXAMPLES.md)
- **Command help:** Add `--help` to any command
- **Issues:** https://github.com/mhenrixon/smart_env/issues

## What Makes smart_env "Smart"?

🧠 **Auto-detection** - Finds .env files automatically  
🔄 **Context switching** - Easy switching between environments  
📌 **Sticky contexts** - Keep specific vars across directories  
🔐 **1Password** - Load secrets securely from vault  
🛡️ **Security first** - Approval, change detection, diffs  
🧹 **Auto-cleanup** - Unsets vars when you leave  
📊 **Tracking** - Always know what's loaded  

---

**Ready to get started?** Just run `smart_env .env` in your project directory!