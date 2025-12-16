# Changelog

All notable changes to smart_env will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2024-12-16

### Fixed

#### PATH Variable Cleanup
- **Critical bug fix**: PATH entries from `.env` files (e.g., `PATH="./bin/:$PATH"`) were accumulating in `$fish_user_paths` and never being removed when changing directories
- This caused commands like `rails` to resolve to the wrong project's `bin/` directory after switching directories with `cd` or bookmark managers like `m`

### Changed

#### PATH Tracking
- **`smart_env`** - Now resolves relative paths (like `./bin`) to absolute paths before adding to PATH
  - Tracks added paths in a new `.paths` file alongside `.vars`
  - Enables proper cleanup when leaving directories

- **`smart_env_unset`** - Now properly removes tracked paths from `$fish_user_paths`
  - Reads paths from `.paths` tracking file
  - Removes each path from `$fish_user_paths` when leaving a directory

- **`smart_env_forget`** - Now cleans up tracked paths when forgetting an env file

- **`smart_env_reset`** - Now removes all tracked paths when resetting approvals

### Technical Details

- New `.paths` tracking files stored in `~/.config/smart_env/variables/`
- Relative paths (`./bin`, `bin/`, `../lib`) are resolved to absolute paths at load time
- Path removal uses index-based deletion from `$fish_user_paths` array

---

## [2.0.0] - 2024-01-15

### Added

#### Context Switching
- **`smart_env_switch`** - New command to easily switch between different environment file contexts
  - Shows available env files in current directory
  - Displays current active context
  - Automatically unloads previous context and loads new one
  - Example: `smart_env_switch .env.demo`

#### Advanced Loading Options
- **`smart_env_load`** - New command for explicit loading with advanced options
  - `--sticky` flag: Keep environment loaded across directory changes
  - `--replace` flag: Replace current context instead of adding to it
  - Context tracking: Sets `SMART_ENV_CURRENT` variable
  - Example: `smart_env_load --sticky .env.credentials`

#### 1Password Integration
- **`smart_env_1password`** - Load environment variables directly from 1Password vaults
  - Load entire items as environment variables
  - `--vault` option: Specify vault name
  - `--field` option: Load only specific fields
  - `--sticky` option: Persist across directory changes
  - `--name` option: Set custom context name
  - Automatic field detection and loading
  - Secure: Uses 1Password CLI (op)
  - Example: `smart_env_1password production-secrets`

- **`smart_env_1password_forget`** - Forget and unload 1Password contexts
  - Lists available 1Password contexts
  - Unsets all variables from context
  - Cleans up tracking files
  - Example: `smart_env_1password_forget production-secrets`

#### Enhanced Context Management
- **`SMART_ENV_CURRENT`** - Global variable tracking the currently active context
- Sticky file support: Environment files can persist across directory changes
- Improved context tracking with metadata files
- Separate storage for 1Password contexts (`~/.config/smart_env/1password/`)

### Changed

#### Updated Commands
- **`smart_env_list`** - Enhanced to show much more information
  - Displays current active context
  - Shows approved environment files with status indicators
  - Lists 1Password contexts with metadata
  - Indicates sticky contexts with 📌 icon
  - Shows loaded status with ✓ icon
  - Displays last loaded timestamp for 1Password contexts

- **`smart_env_unset`** - Now respects sticky contexts
  - Skips unsetting variables from sticky files
  - Handles both file-based and 1Password contexts
  - Improved feedback with context information

- **`smart_env_forget`** - Enhanced with context awareness
  - Clears `SMART_ENV_CURRENT` if forgetting active context
  - Removes sticky file markers
  - Better feedback about what's being forgotten

#### Documentation
- Completely rewritten README with new features
- Added comprehensive EXAMPLES.md with real-world use cases
- Added QUICKSTART.md for quick reference
- Updated all command descriptions and help text

#### Completions
- Added completions for `smart_env_switch`
- Added completions for `smart_env_load` with options
- Added completions for `smart_env_1password` with 1Password item/vault autocomplete
- Enhanced existing completions with better file pattern matching

### Technical Improvements

- Separate storage directories for different context types
- Metadata tracking for 1Password contexts (`.meta` files)
- Sticky file markers (`.sticky` files)
- Improved error handling and user feedback
- Better status indicators and color-coded output
- Consistent use of emojis for visual clarity

### Features Summary

| Feature | Command | Description |
|---------|---------|-------------|
| Context Switching | `smart_env_switch` | Switch between different env files |
| Sticky Loading | `smart_env_load --sticky` | Keep vars across directory changes |
| 1Password | `smart_env_1password` | Load secrets from 1Password |
| Enhanced List | `smart_env_list` | See all contexts and their status |
| Context Tracking | `$SMART_ENV_CURRENT` | Always know what's active |

## [1.0.0] - 2024-01-01

### Initial Release

- Basic .env file loading with approval system
- Change detection with MD5 hashing
- Visual diff support for changed files
- Automatic directory watching
- Auto-unload when leaving directories
- PATH handling with fish_add_path
- Security-focused design
- Privacy-focused (no value display)
- macOS optimized

---

## Migration Guide: 1.x to 2.0

### Breaking Changes
None! Version 2.0 is fully backward compatible with 1.x.

### New Recommended Workflows

#### Before (1.x)
```fish
cd ~/project
smart_env .env
# Manual tracking of what's loaded
```

#### After (2.0)
```fish
cd ~/project
smart_env_switch .env.development
# Automatic context tracking, easy switching
```

#### New: Sticky Credentials
```fish
# Load once, use everywhere
smart_env_load --sticky ~/.config/.env.credentials
```

#### New: 1Password Integration
```fish
# Load secrets from vault
smart_env_1password production-secrets
```

### Upgrade Benefits

1. **Context Awareness** - Always know what environment you're in
2. **Easy Switching** - Switch between environments with one command
3. **Sticky Contexts** - Keep credentials loaded across projects
4. **1Password** - Integrate with your existing secrets management
5. **Better Visibility** - Enhanced `smart_env_list` shows everything

---

For more details, see:
- [README.md](README.md) - Full documentation
- [EXAMPLES.md](EXAMPLES.md) - Real-world examples
- [QUICKSTART.md](QUICKSTART.md) - Quick reference guide