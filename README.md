<img src="https://cdn.rawgit.com/oh-my-fish/oh-my-fish/e4f1c2e0219a17e2c748b824004c8d0b38055c16/docs/logo.svg" align="left" width="144px" height="144px"/>

#### smart_env
> Smart environment variable management for fish shell

[![Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg?style=flat-square)](LICENSE)
[![Fish Shell Version](https://img.shields.io/badge/fish-v3.0.0-007EC7.svg?style=flat-square)](https://fishshell.com)
[![Oh My Fish Framework](https://img.shields.io/badge/Oh%20My%20Fish-Framework-007EC7.svg?style=flat-square)](https://www.github.com/oh-my-fish/oh-my-fish)

<br/>

Automatically and securely loads environment variables from .env files, with change detection, diffing, and automatic unloading when leaving directories.

## Install

```fish
$ omf install smart_env
```

## Features

- **Automatic Directory Handling:** Variables are automatically unset when leaving a directory
- **Change Detection:** Notifies when env file contents change
- **Visual Diff Support:** See what changed in your environment files
- **Security Focused:** Requires approval for loading env files
- **Automatic Mode:** Can automatically load common .env files in directories

## Usage

### Load environment files
```fish
$ smart_env .env .env.development
```

### List approved env files
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
- Unsets variables when leaving a directory
- Loads common .env files (.env, .env.local, .env.development) when entering directories with them


# License

[Unlicense][unlicense] © [mhenrixon][author] et [al][contributors]


[unlicense]:      https://unlicense.org
[author]:         https://github.com/mhenrixon
[contributors]:   https://github.com/mhenrixon/smart_env/graphs/contributors
[omf-link]:       https://www.github.com/oh-my-fish/oh-my-fish

[license-badge]:  https://img.shields.io/badge/license-MIT-007EC7.svg?style=flat-square