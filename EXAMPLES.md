# smart_env Examples

This document provides practical examples for using `smart_env` with its advanced features.

## Table of Contents

- [Basic Usage](#basic-usage)
- [Context Switching](#context-switching)
- [Sticky Environments](#sticky-environments)
- [1Password Integration](#1password-integration)
- [Managing Contexts](#managing-contexts)
- [Common Workflows](#common-workflows)

## Basic Usage

### Load a single .env file

```fish
$ smart_env .env
```

### Load multiple .env files

```fish
$ smart_env .env .env.local .env.development
```

Variables from later files will override earlier ones.

## Context Switching

### Show available env files and current context

```fish
$ smart_env_switch
Current context: /Users/you/project/.env.production

Available env files in current directory:
  → .env.production (active)
  • .env.staging
  • .env.development
  • .env.demo
```

### Switch to a different environment

```fish
# Switch from production to demo
$ smart_env_switch .env.demo
📤 Unloading current context: .env.production
📥 Switching to context: .env.demo
✅ Context switched to: .env.demo
```

This automatically:
1. Unloads all variables from `.env.production`
2. Loads all variables from `.env.demo`
3. Tracks the new context

### Use case: Testing different configurations

```fish
# Test with production config
$ smart_env_switch .env.production
$ ./run-tests.sh

# Switch to staging config
$ smart_env_switch .env.staging
$ ./run-tests.sh

# Switch to demo config
$ smart_env_switch .env.demo
$ ./run-demo.sh
```

## Sticky Environments

Sticky environments persist across directory changes. This is useful for credentials or settings you want available everywhere.

### Load a sticky environment

```fish
$ smart_env_load --sticky .env.credentials
📥 Loading: .env.credentials
✅ Loaded environment from .env.credentials
  Variables set: AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
📌 Marked as sticky (won't unload on directory change)
```

### Example: API keys that you need everywhere

```fish
# In your home directory or project root
$ cd ~/projects/my-app
$ smart_env_load --sticky .env.api-keys

# Now change to any subdirectory
$ cd frontend
$ cd ../backend
$ cd /tmp

# The API keys are still available!
$ echo $API_KEY
your-api-key-here
```

### Replace current context

```fish
# Load initial environment
$ smart_env_load .env.development

# Replace it entirely with staging
$ smart_env_load --replace .env.staging
```

## 1Password Integration

### Prerequisites

```fish
# Install 1Password CLI
$ brew install 1password-cli

# Sign in to 1Password
$ op signin
```

### Set up secrets in 1Password

Create an item in 1Password with fields like:

- **Item Name:** `my-app-production`
- **Fields:**
  - `DATABASE_URL` = `postgresql://user:pass@host/db`
  - `API_KEY` = `sk_live_abc123`
  - `SECRET_TOKEN` = `very_secret_value`
  - `AWS_ACCESS_KEY_ID` = `AKIA...`
  - `AWS_SECRET_ACCESS_KEY` = `secret...`

### Load secrets from 1Password

```fish
$ smart_env_1password my-app-production
🔐 Loading secrets from 1Password item: my-app-production
  ✓ DATABASE_URL
  ✓ API_KEY
  ✓ SECRET_TOKEN
  ✓ AWS_ACCESS_KEY_ID
  ✓ AWS_SECRET_ACCESS_KEY
✅ Loaded 5 variable(s) from 1Password
Variables loaded: DATABASE_URL API_KEY SECRET_TOKEN AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
```

### Load from a specific vault

```fish
$ smart_env_1password --vault "Work" production-secrets
```

### Load as sticky (persist across directories)

```fish
$ smart_env_1password --sticky production-secrets
🔐 Loading secrets from 1Password item: production-secrets
  ✓ DATABASE_URL
  ✓ API_KEY
✅ Loaded 2 variable(s) from 1Password
📌 Marked as sticky (won't unload on directory change)
```

### Load only a specific field

```fish
# Only load the DATABASE_URL field
$ smart_env_1password --field DATABASE_URL my-app-secrets
```

### Use case: Development with production-like data

```fish
# Load production secrets from 1Password
$ smart_env_1password --vault "Production" database-credentials

# Override specific values with local development ones
$ smart_env_load .env.local

# Now you have production database credentials but local API endpoints
```

## Managing Contexts

### List all contexts

```fish
$ smart_env_list
📍 Current context:
  → /Users/you/project/.env.production

📄 Approved environment files:
  • /Users/you/project/.env ✓ (loaded)
  • /Users/you/project/.env.production ✓ (loaded)
  • /Users/you/project/.env.staging
  • /Users/you/api-keys/.env.credentials 📌 (sticky)

🔐 1Password contexts:
  • production-secrets ✓ (loaded)
    Last loaded: 2024-01-15T10:30:00Z
  • staging-secrets
    Last loaded: 2024-01-14T15:20:00Z
```

### Forget a file context

```fish
$ smart_env_forget .env.production
✅ Forgotten and unset: .env.production
```

### Forget a 1Password context

```fish
$ smart_env_1password_forget production-secrets
📤 Unset variables: DATABASE_URL API_KEY SECRET_TOKEN
✅ Forgotten 1Password context: production-secrets
```

### Reset all approvals

```fish
$ smart_env_reset
Are you sure you want to reset all approved environment files? [y/N] y
✅ All approvals reset
```

## Common Workflows

### Workflow 1: Multi-environment development

```fish
# Morning: Start with development
$ cd ~/projects/my-app
$ smart_env_switch .env.development

# Afternoon: Test against staging
$ smart_env_switch .env.staging
$ npm run e2e-tests

# Evening: Quick production check
$ smart_env_switch .env.production
$ npm run health-check
```

### Workflow 2: Shared credentials + project-specific config

```fish
# Load shared AWS credentials (sticky)
$ cd ~/.aws
$ smart_env_load --sticky .env.aws-credentials

# Load project-specific config
$ cd ~/projects/frontend
$ smart_env .env

# Load different project
$ cd ~/projects/backend
$ smart_env .env

# AWS credentials are still available in both projects!
```

### Workflow 3: Using 1Password for secrets, files for config

```fish
# Load secrets from 1Password (sticky)
$ smart_env_1password --sticky production-secrets

# Load application config from file
$ cd ~/projects/my-app
$ smart_env .env.production

# Now you have:
# - Secrets from 1Password (DATABASE_URL, API_KEY, etc.)
# - Config from .env.production (PORT, LOG_LEVEL, etc.)
```

### Workflow 4: Demo environment with sanitized data

```fish
# Create .env.demo with safe, demo-appropriate values
$ cat .env.demo
DATABASE_URL=postgresql://localhost/demo_db
API_KEY=demo_key_12345
FEATURE_FLAGS=new_ui:true,beta_features:true

# Switch to demo for presentations
$ smart_env_switch .env.demo

# Run your demo
$ npm run start

# Switch back to development when done
$ smart_env_switch .env.development
```

### Workflow 5: Temporary environment override

```fish
# Load base environment
$ smart_env .env

# Temporarily load overrides for debugging
$ smart_env_load --replace .env.debug

# When done, switch back
$ smart_env_switch .env
```

### Workflow 6: CI/CD-like environment testing

```fish
# Test the deployment process with each environment
$ for env in development staging production
    smart_env_switch .env.$env
    echo "Testing with $env environment..."
    ./run-integration-tests.sh
end
```

## Tips and Tricks

### Quickly check what's loaded

```fish
$ smart_env_list
```

### See all environment variables (including from smart_env)

```fish
$ env | grep -E '(DATABASE|API|AWS)'
```

### Combine with direnv compatibility

Since `smart_env` watches directory changes, it works well alongside other tools. Just be aware of load order.

### Keep sensitive files out of git

```fish
# In your .gitignore
.env
.env.*
!.env.example
```

### Create an example file

```fish
# Create a safe example for your team
$ cat .env.example
DATABASE_URL=postgresql://localhost/myapp_dev
API_KEY=your_api_key_here
SECRET_TOKEN=your_secret_token_here

# Document it
$ echo "Copy .env.example to .env.development and fill in your values" >> README.md
```

### Audit what's loaded

```fish
# See which files are being tracked
$ ls -la ~/.config/smart_env/variables/

# See the variables from a specific file
$ cat ~/.config/smart_env/variables/_Users_you_project_.env.vars
```

## Troubleshooting

### Variables not loading

```fish
# Check if the file is approved
$ smart_env_list

# Try loading with explicit approval
$ smart_env .env.development
```

### Variables not unloading when changing directories

```fish
# Check if marked as sticky
$ smart_env_list

# Manually unset
$ smart_env_unset
```

### 1Password not working

```fish
# Check if op CLI is installed
$ op --version

# Check if signed in
$ op account list

# Sign in if needed
$ op signin
```

### Want to start fresh

```fish
# Reset everything
$ smart_env_reset

# Or manually clean up
$ rm -rf ~/.config/smart_env/
```
