function smart_env_switch --description "Switch between different environment file contexts"
    set -l storage_dir ~/.config/smart_env
    mkdir -p $storage_dir/cache
    mkdir -p $storage_dir/variables

    # If no argument provided, show current context and available files
    if test (count $argv) -eq 0
        if set -q SMART_ENV_CURRENT
            set_color cyan
            echo "Current context: $SMART_ENV_CURRENT"
            set_color normal
        else
            set_color yellow
            echo "No context currently active"
            set_color normal
        end

        # Show available env files in current directory
        set -l available_envs
        for pattern in .env .env.* *.env
            for env_file in $pattern
                if test -f $env_file
                    set -a available_envs $env_file
                end
            end
        end

        if test (count $available_envs) -gt 0
            set_color cyan
            echo ""
            echo "Available env files in current directory:"
            for env in $available_envs
                if set -q SMART_ENV_CURRENT; and test "$SMART_ENV_CURRENT" = (realpath $env)
                    echo "  → $env (active)"
                else
                    echo "  • $env"
                end
            end
            set_color normal
        end

        return 0
    end

    set -l env_file $argv[1]

    # Check if the file exists
    if not test -f $env_file
        set_color red
        echo "❌ File not found: $env_file"
        set_color normal
        return 1
    end

    # Get absolute path for tracking
    set -l new_path
    if string match -q "/*" $env_file
        set new_path $env_file
    else
        set new_path $PWD/$env_file
    end

    # Check if we're already using this context
    if set -q SMART_ENV_CURRENT; and test "$SMART_ENV_CURRENT" = "$new_path"
        set_color yellow
        echo "⚠️  Already using context: $env_file"
        set_color normal
        return 0
    end

    # Unload current context if one exists
    if set -q SMART_ENV_CURRENT
        set_color yellow
        echo "📤 Unloading current context: "(basename $SMART_ENV_CURRENT)
        set_color normal

        # Forget the current env file (this unsets variables)
        smart_env_forget $SMART_ENV_CURRENT 2>/dev/null
    end

    # Load the new context
    set_color cyan
    echo "📥 Switching to context: $env_file"
    set_color normal

    # Load the new env file
    smart_env $env_file

    # Track the current context globally
    set -gx SMART_ENV_CURRENT $new_path

    set_color green
    echo "✅ Context switched to: $env_file"
    set_color normal
end