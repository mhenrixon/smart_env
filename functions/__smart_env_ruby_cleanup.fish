function __smart_env_ruby_cleanup --description "Clean up Ruby/Bundler environment variables that may leak between projects"
    # List of Ruby-related environment variables that should be cleared between projects
    # These are typically set by bundler, rbenv, rvm, chruby, or project-specific configs
    set -l ruby_vars \
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
        GEM_HOME \
        GEM_PATH \
        GEM_ROOT \
        RUBYOPT \
        RUBYLIB \
        RUBY_VERSION \
        RBENV_VERSION \
        RBENV_DIR \
        RBENV_ROOT \
        RVM_ENV \
        RVM_PATH \
        RVM_RUBY_VERSION \
        CHRUBY_VERSION \
        CHRUBY_ROOT

    set -l cleared_vars

    for var in $ruby_vars
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

    # Clean up project-specific bin directories from PATH
    # This handles mise/asdf/rbenv shims and project bin directories
    set -l cleaned_paths
    set -l current_project_root (git rev-parse --show-toplevel 2>/dev/null; or echo "")

    for p in $PATH
        # Skip if it's a project bin directory that's not the current project
        # Match patterns like /path/to/project/bin or /path/to/project/.bundle/bin
        if string match -q "*/bin" $p
            # Check if this is a Code directory (common project parent)
            if string match -q "*/Code/*" $p
                # Extract the project path from the bin path
                set -l project_path (string replace "/bin" "" $p)
                set -l project_path (string replace "/.bundle" "" $project_path)

                # If it's not the current project, skip it (remove from PATH)
                if test -n "$current_project_root" -a "$project_path" != "$current_project_root"
                    set -a cleaned_paths $p
                    continue
                end

                # If we're not in a git repo but this looks like another project, skip it
                if test -z "$current_project_root" -a "$project_path" != "$PWD"
                    # Check if this directory still exists and is a different project
                    if test -d "$project_path" -a "$project_path" != "$PWD"
                        set -a cleaned_paths $p
                        continue
                    end
                end
            end
        end
    end

    # Remove the cleaned paths from PATH
    if test (count $cleaned_paths) -gt 0
        for clean_path in $cleaned_paths
            set -l idx (contains -i $clean_path $PATH)
            if test -n "$idx"
                set -e PATH[$idx]
            end
        end
    end

    # Report what was cleaned if anything
    if test (count $cleared_vars) -gt 0 -o (count $cleaned_paths) -gt 0
        set_color yellow
        echo "🧹 Ruby environment cleanup:"
        set_color normal

        if test (count $cleared_vars) -gt 0
            set_color green
            echo "   Cleared variables: $cleared_vars"
            set_color normal
        end

        if test (count $cleaned_paths) -gt 0
            set_color green
            echo "   Removed stale paths:"
            for p in $cleaned_paths
                echo "     - $p"
            end
            set_color normal
        end
    end
end
