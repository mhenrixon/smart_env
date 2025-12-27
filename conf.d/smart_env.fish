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

# Run cleanup once at startup to handle:
# 1. Variables from previous sessions
# 2. Inherited environment from duplicated iTerm2 panes (CMD+D, CMD+SHIFT+D)
# 3. Stale Ruby/Bundler environment from other projects
function __run_smart_env_unset_on_startup --on-event fish_prompt
    # First clean up from previous sessions if needed
    smart_env_unset

    # Clean up Bundler environment that may have been inherited
    # This is critical for iTerm2 split panes which inherit parent environment
    if functions -q __smart_env_bundler_cleanup
        __smart_env_bundler_cleanup
    end

    # CRITICAL: Reset Ruby environment to handle inherited state from split panes
    # This clears GEM_HOME, GEM_PATH, RUBY_ROOT etc. so chruby can set them fresh
    # Without this, the inherited GEM_HOME from another project causes gem conflicts
    if functions -q chruby_reset
        chruby_reset
    end

    # Force mise to re-evaluate for the current directory (for node/bun, not ruby)
    # Ruby is managed by chruby, not mise
    if command -q mise
        eval (mise hook-env -s fish 2>/dev/null)
    end

    # Re-apply chruby for the current directory's Ruby version
    # This will check for .ruby-version and set up the correct environment
    if functions -q chruby_auto
        chruby_auto
    end

    # If no .ruby-version was found, chruby_auto won't activate any Ruby
    # In that case, activate the default Ruby version if chruby is available
    if functions -q chruby; and not set -q RUBY_ROOT
        # Check if there's a default Ruby to activate (3.4.7)
        if test -d "$HOME/.rubies/ruby-3.4.7"
            chruby 3.4.7
        end
    end

    # Check for .env file in current directory
    if test -f .env
        smart_env .env
    end

    # Prepend ./bin to PATH if enabled and bin directory exists
    # This runs AFTER mise's hook to ensure ./bin is first
    if set -q SMART_ENV_PREPEND_BIN; and test "$SMART_ENV_PREPEND_BIN" = true
        if test -d "$PWD/bin"
            # Remove any existing ./bin or $PWD/bin from PATH first
            set -l new_path
            for p in $PATH
                if test "$p" != "$PWD/bin"; and test "$p" != "./bin"
                    set -a new_path $p
                end
            end
            # Prepend the current project's bin directory
            set -gx PATH "$PWD/bin" $new_path
        end
    end

    # Remove this startup function so it only runs once
    functions -e __run_smart_env_unset_on_startup
end
