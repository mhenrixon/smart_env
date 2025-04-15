function __smart_env_directory_watcher --on-variable PWD --description "Auto-load/unload environment variables when changing directories"
    # First unset variables from directories we've left
    smart_env_unset
    
    # Now check if we have env files to load in the current directory
    set -l env_files
    
    # Check for common env files
    for pattern in .env .env.local .env.development
        if test -f $pattern
            set -a env_files $pattern
        end
    end
    
    # If we found any env files, load them
    if test (count $env_files) -gt 0
        smart_env $env_files
    end
end
