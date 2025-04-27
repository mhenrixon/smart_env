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
    
    # Clear the recursion guard
    set -e __smart_env_in_progress
end
