function __smart_env_directory_watcher --on-variable PWD --description "Auto-load/unload environment variables when changing directories"
    # Prevent recursion - if we're already processing a directory change, skip this one
    if set -q __smart_env_in_progress
        return 0
    end
    
    # Set the recursion guard
    set -g __smart_env_in_progress 1
    
    # Save old and new directory for checks
    set -l old_dir $__smart_env_prev_dir
    set -l new_dir $PWD
    
    # Skip if the directory hasn't actually changed (sometimes PWD can be set to same value)
    if test "$old_dir" = "$new_dir"
        set -e __smart_env_in_progress
        return 0
    end
    
    # Update the previous directory tracking
    set -g __smart_env_prev_dir $PWD
    
    # If this is the first run, don't unset anything
    if test -z "$old_dir"
        # Just initialize things
    else
        # Clean up variables from the previous directory
        # This must happen before we load new ones
        smart_env_unset

        # Clean up Bundler environment variables that may have leaked
        if functions -q __smart_env_bundler_cleanup
            __smart_env_bundler_cleanup
        end

        # Reset Ruby environment before re-applying chruby
        # This ensures we don't have stale GEM_HOME/GEM_PATH from the previous directory
        if functions -q chruby_reset
            chruby_reset
        end

        # Re-apply chruby after cleanup to ensure Ruby environment is correct
        # for the new directory (handles .ruby-version files)
        if functions -q chruby_auto
            chruby_auto
        end

        # If no .ruby-version was found, activate default Ruby
        if functions -q chruby; and not set -q RUBY_ROOT
            if test -d "$HOME/.rubies/ruby-3.4.7"
                chruby 3.4.7
            end
        end
    end
    
    # Check for .env files in the new directory
    set -l env_files
    
    # Check for common env file patterns right in this directory
    for pattern in .env .env.local .env.development .env.local.development
        if test -f $pattern
            set -a env_files $pattern
        end
    end
    
    # If we found any env files, load them
    if test (count $env_files) -gt 0
        set_color cyan
        echo "🔄 Found environment files in $PWD"
        set_color normal
        # This sets new variables and tracks them
        smart_env $env_files
    end

    # Prepend ./bin to PATH if enabled and bin directory exists
    # This runs AFTER mise's hook to ensure ./bin is first
    if set -q SMART_ENV_PREPEND_BIN; and test "$SMART_ENV_PREPEND_BIN" = "true"
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

    # Clear the recursion guard
    set -e __smart_env_in_progress
end
