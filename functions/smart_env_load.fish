function smart_env_load --description "Explicitly load an environment file and set it as current context"
    set -l storage_dir ~/.config/smart_env
    mkdir -p $storage_dir/cache
    mkdir -p $storage_dir/variables

    set -l sticky 0
    set -l replace 0
    set -l env_files

    # Parse options
    for arg in $argv
        switch $arg
            case -s --sticky
                set sticky 1
            case -r --replace
                set replace 1
            case -h --help
                echo "Usage: smart_env_load [OPTIONS] ENV_FILE..."
                echo ""
                echo "Options:"
                echo "  -s, --sticky    Keep loaded even when changing directories"
                echo "  -r, --replace   Replace current context instead of adding to it"
                echo "  -h, --help      Show this help message"
                echo ""
                echo "Examples:"
                echo "  smart_env_load .env.demo"
                echo "  smart_env_load --sticky .env.production"
                echo "  smart_env_load --replace .env.staging"
                return 0
            case '*'
                set -a env_files $arg
        end
    end

    # Check if we have files to load
    if test (count $env_files) -eq 0
        set_color red
        echo "❌ No environment file specified"
        echo "Usage: smart_env_load [OPTIONS] ENV_FILE..."
        echo "Try 'smart_env_load --help' for more information"
        set_color normal
        return 1
    end

    # If replace mode, unload current context first
    if test $replace -eq 1; and set -q SMART_ENV_CURRENT
        set_color yellow
        echo "📤 Replacing current context"
        set_color normal
        smart_env_forget $SMART_ENV_CURRENT 2>/dev/null
        set -e SMART_ENV_CURRENT
    end

    # Process each env file
    set -l loaded_files
    for env_file in $env_files
        if not test -f $env_file
            set_color red
            echo "❌ File not found: $env_file"
            set_color normal
            continue
        end

        # Get absolute path
        set -l abs_path
        if string match -q "/*" $env_file
            set abs_path $env_file
        else
            set abs_path $PWD/$env_file
        end

        # Load the env file using smart_env
        set_color cyan
        echo "📥 Loading: $env_file"
        set_color normal

        smart_env $env_file

        # Track as loaded
        set -a loaded_files $abs_path

        # If sticky mode, mark this file as sticky
        if test $sticky -eq 1
            set -l sticky_file $storage_dir/variables/(echo $abs_path | string replace -a / _ | string replace -a : _).sticky
            touch $sticky_file
            set_color cyan
            echo "📌 Marked as sticky (won't unload on directory change)"
            set_color normal
        end
    end

    # Set the current context to the last loaded file
    if test (count $loaded_files) -gt 0
        set -gx SMART_ENV_CURRENT $loaded_files[-1]

        set_color green
        echo "✅ Loaded "(count $loaded_files)" environment file(s)"
        set_color normal

        # Show current context
        set_color cyan
        echo "Current context: "(basename $SMART_ENV_CURRENT)
        set_color normal
    end
end