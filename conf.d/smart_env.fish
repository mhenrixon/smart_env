# Auto-loaded initialization for smart_env package
# This file is sourced automatically when the shell starts

# Set default storage directory if not already set
set -q SMART_ENV_DIR; or set -g SMART_ENV_DIR ~/.config/smart_env

# Create storage directories if they don't exist
mkdir -p $SMART_ENV_DIR/cache
mkdir -p $SMART_ENV_DIR/variables
