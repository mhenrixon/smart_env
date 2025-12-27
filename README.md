<img src="https://cdn.rawgit.com/oh-my-fish/oh-my-fish/e4f1c2e0219a17e2c748b824004c8d0b38055c16/docs/logo.svg" align="left" width="144px" height="144px"/>

#### smart_env

> Smart environment variable management for fish shell

[![CI](https://github.com/mhenrixon/smart_env/actions/workflows/ci.yml/badge.svg)](https://github.com/mhenrixon/smart_env/actions/workflows/ci.yml)
[![Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg?style=flat-square)](LICENSE)
[![Fish Shell Version](https://img.shields.io/badge/fish-v3.0.0-007EC7.svg?style=flat-square)](https://fishshell.com)
[![Oh My Fish Framework](https://img.shields.io/badge/Oh%20My%20Fish-Framework-007EC7.svg?style=flat-square)](https://www.github.com/oh-my-fish/oh-my-fish)

<br/>

Automatically and securely loads environment variables from .env files and 1Password, with change detection, diffing, context switching, and automatic unloading when leaving directories.

## Install

```fish
$ omf install smart_env
```

## Features

- **Automatic Directory Handling:** Variables are automatically unset when leaving a directory
- **Change Detection:** Notifies when env file contents change
- **Visual Diff Support:** See what changed in your environment files
- **Context Switching:** Easily switch between different env file contexts (.env.demo, .env.staging, etc.)
- **Sticky Contexts:** Keep specific env files loaded across directory changes
- **1Password Integration:** Load environment variables directly from 1Password vaults
- **Security Focused:** Requires approval for loading env files and preserves sensitive information
- **Automatic Mode:** Can automatically load common .env files in directories
- **Safe PATH Handling:** Safely manages PATH variables using fish_add_path
- **Privacy Focused:** Does not display sensitive environment variable values
- **macOS Optimized:** Fully compatible with macOS

## Usage

### Load environment files

```fish
$ smart_env .env .env.development
```

### Switch between environment contexts

```fish
# Show available env files and current context
$ smart_env_switch

# Switch to a different env file (unloads current, loads new)
$ smart_env_switch .env.demo
$ smart_env_switch .env.staging
```

### Load specific env files with options

```fish
# Load a file explicitly
$ smart_env_load .env.production

# Load and keep across directory changes (sticky)
$ smart_env_load --sticky .env.production

# Replace current context
$ smart_env_load --replace .env.demo
```

### Load from 1Password

```fish
# Load environment variables from a 1Password item
$ smart_env_1password production-secrets

# Load from a specific vault
$ smart_env_1password --vault MyVault my-secrets

# Keep loaded across directories (sticky)
$ smart_env_1password --sticky production-secrets

# Load only a specific field
$ smart_env_1password --field DATABASE_URL my-secrets
```

### List approved env files and contexts

```fish
$ smart_env_list
```

### Forget/unset a specific env file

```fish
$ smart_env_forget .env.local
```

### Reset all approvals

```fish
$ smart_env_reset
```

## Directory Auto-Detection

The package automatically watches directory changes and:

- Unsets variables when leaving a directory (unless marked as sticky)
- Loads common .env files (.env, .env.local, .env.development) when entering directories with them
- Respects sticky contexts that persist across directory changes

## 1Password Integration

To use 1Password integration, you need:

1. **Install 1Password CLI:**

    ```fish
    $ brew install 1password-cli
    ```

2. **Sign in to 1Password:**

    ```fish
    $ op signin
    ```

3. **Set up your secrets in 1Password:**
    - Create an item in 1Password with fields for each environment variable
    - Each field label should be the variable name (e.g., `DATABASE_URL`, `API_KEY`)
    - Field values should contain the actual secrets

4. **Load the secrets:**
    ```fish
    $ smart_env_1password my-app-secrets
    ```

The secrets will be loaded into your environment just like .env files, with the same security and tracking features.

## Ruby/chruby Integration

smart_env integrates with [chruby](https://github.com/postmodern/chruby) to properly manage Ruby environments when switching directories. This is especially important for:

- **iTerm2 split panes** (CMD+D, CMD+SHIFT+D) which inherit parent environment
- **Switching between projects** with different Ruby versions
- **Preventing gem conflicts** from stale GEM_HOME/GEM_PATH variables

### Setup chruby Integration

If you use chruby for Ruby version management, run the setup script to ensure proper integration:

```fish
fish ~/.config/omf/pkg/smart_env/scripts/setup_chruby.fish
```

This script will:
1. Check if chruby is installed
2. Update your `~/.config/fish/config.fish` to source all required chruby functions
3. Remove any broken custom `chruby_use` functions

### Manual Setup

If you prefer manual setup, ensure your `~/.config/fish/config.fish` includes:

```fish
# Source all chruby functions (order matters!)
source /opt/homebrew/opt/chruby-fish/share/fish/vendor_functions.d/chruby_reset.fish
source /opt/homebrew/opt/chruby-fish/share/fish/vendor_functions.d/chruby_use.fish
source /opt/homebrew/opt/chruby-fish/share/fish/vendor_functions.d/chruby.fish
source /opt/homebrew/opt/chruby-fish/share/fish/vendor_conf.d/chruby_auto.fish

# Set default Ruby version
chruby ruby-3.4  # or your preferred version
```

> **Note:** On Linux, the path may be `/usr/local/share/fish/vendor_functions.d/` instead.

### What This Fixes

Without proper chruby integration, you may see errors like:

```
Ignoring bigdecimal-4.0.1 because its extensions are not built
You must use Bundler 4 or greater with this lockfile
```

These occur when `GEM_HOME` and `GEM_PATH` from a previous project "leak" into new shell sessions.

## Configuration

### Enable ./bin PATH Prepending

To automatically prepend `./bin` to your PATH when entering directories (useful for Rails binstubs):

```fish
set -gx SMART_ENV_PREPEND_BIN true
```

Add this to your `~/.config/fish/config.fish`.

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues and solutions.

## Development

### Running Tests

```fish
./scripts/test.fish
```

### Linting

```fish
# Check for issues
./scripts/lint.fish

# Auto-fix formatting
./scripts/lint.fish --fix
```

# License

[Unlicense][unlicense] © [mhenrixon][author] et [al][contributors]

[unlicense]: https://unlicense.org
[author]: https://github.com/mhenrixon
[contributors]: https://github.com/mhenrixon/smart_env/graphs/contributors
[omf-link]: https://www.github.com/oh-my-fish/oh-my-fish
[license-badge]: https://img.shields.io/badge/license-MIT-007EC7.svg?style=flat-square
