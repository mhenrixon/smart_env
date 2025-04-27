# Auto-loaded initialization for smart_env package
# This file is sourced automatically when the shell starts

# Set default storage directory if not already set
set -q SMART_ENV_DIR; or set -g SMART_ENV_DIR ~/.config/smart_env

# Create storage directories if they don't exist
mkdir -p $SMART_ENV_DIR/cache
mkdir -p $SMART_ENV_DIR/variables

# Initialize the directory tracking variable
set -g __smart_env_prev_dir $PWD

# If there's no directory watcher function registered yet, ensure it's loaded
functions -q __smart_env_directory_watcher; or source (status dirname)/../functions/__smart_env_directory_watcher.fish

# Run unset once at startup to clean up any variables from directories we're not in
function __run_smart_env_unset_on_startup --on-event fish_prompt
    # First clean up from previous sessions if needed
    smart_env_unset
    
    # Check for .env file in current directory
    if test -f .env
        smart_env .env
    end
    
    # Remove this startup function so it only runs once
    functions -e __run_smart_env_unset_on_startup
end
