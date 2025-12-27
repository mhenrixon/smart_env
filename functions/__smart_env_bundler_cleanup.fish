function __smart_env_bundler_cleanup --description "Clean up Bundler environment variables that may leak between projects (chruby-safe)"
    # List of Bundler-related environment variables that should be cleared between projects
    # NOTE: We intentionally DO NOT clear GEM_HOME, GEM_PATH, GEM_ROOT, CHRUBY_VERSION, CHRUBY_ROOT
    # because those are managed by chruby
    set -l bundler_vars \
        BUNDLE_GEMFILE \
        BUNDLE_PATH \
        BUNDLE_BIN \
        BUNDLE_APP_CONFIG \
        BUNDLE_WITHOUT \
        BUNDLE_WITH \
        BUNDLE_DEPLOYMENT \
        BUNDLE_FROZEN \
        BUNDLE_JOBS \
        BUNDLE_RETRY \
        BUNDLE_CACHE_PATH \
        BUNDLE_DISABLE_SHARED_GEMS \
        BUNDLE_IGNORE_CONFIG \
        RUBYOPT \
        RUBYLIB

    set -l cleared_vars

    for var in $bundler_vars
        # Check if the variable is set
        if set -q $var
            # Get the current value for logging
            set -l current_value (eval echo \$$var)

            # Only clear if it's set and not empty
            if test -n "$current_value"
                set -e $var
                set -a cleared_vars $var
            end
        end
    end

    # NOTE: We intentionally do NOT modify PATH here.
    # The previous logic that tried to clean up "stale" project bin directories
    # was too aggressive and would incorrectly remove the current project's bin
    # directory, especially after cancelling long-running commands.
    #
    # PATH management is handled by:
    # - chruby_auto (for Ruby paths)
    # - smart_env (for ./bin via SMART_ENV_PREPEND_BIN)
    # - The directory watcher (when changing directories)
end
