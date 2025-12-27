function smart_env --description "Simple environment loader with change detection"
    # Create storage directory if it doesn't exist
    set -l storage_dir ~/.config/smart_env
    mkdir -p $storage_dir/cache
    mkdir -p $storage_dir/variables

    # Process each env file
    for env_file in $argv
        if test -f $env_file
            # Get absolute path without using cd (which would trigger PWD changes)
            set -l abs_path

            # Handle absolute paths directly
            if string match -q "/*" $env_file
                set abs_path $env_file
            else
                # For relative paths, use PWD
                set abs_path $PWD/$env_file
            end
            # Get hash with md5
            set -l file_hash (md5 -q $abs_path)
            set -l hash_file $storage_dir/(echo $abs_path | string replace -a / _ | string replace -a : _).hash
            set -l cache_file $storage_dir/cache/(echo $abs_path | string replace -a / _ | string replace -a : _).env
            set -l vars_file $storage_dir/variables/(echo $abs_path | string replace -a / _ | string replace -a : _).vars
            set -l paths_file $storage_dir/variables/(echo $abs_path | string replace -a / _ | string replace -a : _).paths
            set -l dir_track_file $storage_dir/variables/(echo $abs_path | string replace -a / _ | string replace -a : _).dir

            set -l load_file 0
            set -l old_hash ""

            # Check if we've seen this file before
            if test -f $hash_file
                set old_hash (cat $hash_file)

                # If hash matches, load it
                if test $old_hash = $file_hash
                    set load_file 1
                    set_color green
                    echo "Loading approved file: $env_file"
                    set_color normal
                else
                    # Hash doesn't match - file has changed
                    set_color yellow
                    echo "⚠️  Changes detected in $env_file"
                    set_color normal

                    # Show diff if cached version exists
                    if test -f $cache_file
                        echo "Changes:"
                        set_color cyan
                        diff $cache_file $abs_path
                        set_color normal
                    end

                    # Ask for confirmation
                    read -l -P "Load this modified .env file? (y/n/a) [y=yes, n=no, a=approve for future] " confirm

                    switch $confirm
                        case y yes Y
                            set load_file 1
                        case a approve A
                            set load_file 1
                            echo $file_hash > $hash_file
                            cp $abs_path $cache_file
                            set_color green
                            echo "✅ File approved for automatic loading"
                            set_color normal
                        case '*'
                            set_color red
                            echo "❌ Skipping file: $env_file"
                            set_color normal
                    end
                end
            else
                # First time seeing this file
                set_color yellow
                echo "⚠️  New .env file detected: $env_file"
                echo "Contents:"
                set_color cyan
                cat $abs_path
                set_color normal

                read -l -P "Load this .env file? (y/n/a) [y=yes, n=no, a=approve for future] " confirm

                switch $confirm
                    case y yes Y
                        set load_file 1
                    case a approve A
                        set load_file 1
                        echo $file_hash > $hash_file
                        cp $abs_path $cache_file
                        set_color green
                        echo "✅ File approved for automatic loading"
                        set_color normal
                    case '*'
                        set_color red
                        echo "❌ Skipping file: $env_file"
                        set_color normal
                end
            end

            # Load the env file if approved
            if test $load_file -eq 1
                # Clear tracked variables and paths for this file
                echo -n "" >$vars_file
                echo -n "" >$paths_file

                # Store the current directory with this env file
                echo $PWD > $dir_track_file

                # Track which variables we've set
                set -l set_variables
                set -l added_paths

                # Variables that should NEVER be set from .env files
                # These are managed by chruby, mise, or the system
                set -l protected_vars \
                    RUBY_VERSION RUBY_ENGINE RUBY_ROOT RUBYOPT RUBYLIB \
                    GEM_HOME GEM_PATH GEM_ROOT \
                    CHRUBY_VERSION CHRUBY_ROOT RUBY_AUTO_VERSION \
                    RBENV_VERSION RBENV_ROOT \
                    SHELL USER HOME TERM

                # Load and track the new variables
                for line in (cat $abs_path | grep -v '^#' | grep -v '^\s*$')
                    set item (string split -m 1 '=' $line)
                    if test (count $item) -eq 2
                        set var_name $item[1]
                        set var_value $item[2]

                        # Skip protected variables
                        if contains -- $var_name $protected_vars
                            set_color yellow
                            echo "  ⚠️  Skipping protected variable: $var_name (managed by system/chruby)"
                            set_color normal
                            continue
                        end

                        # Handle PATH specially
                        if test "$var_name" = PATH
                            # Handle path components
                            for path_part in (string split ":" $var_value)
                                if test -n "$path_part"
                                    # Resolve relative paths to absolute paths
                                    set -l abs_path_part
                                    if string match -q "./*" $path_part
                                        # Relative path starting with ./
                                        set abs_path_part $PWD/(string replace "./" "" $path_part)
                                    else if string match -q "/*" $path_part
                                        # Already absolute
                                        set abs_path_part $path_part
                                    else
                                        # Relative path without ./
                                        set abs_path_part $PWD/$path_part
                                    end
                                    # Use fish_add_path to safely modify PATH
                                    fish_add_path -p $abs_path_part
                                    set -a added_paths $abs_path_part
                                end
                            end
                        else
                            # Set regular variables as global exported
                            set -gx $var_name $var_value
                            set -a set_variables $var_name
                        end

                        # Always track the variable so we can unset it
                        echo $var_name >> $vars_file
                    end
                end

                # Save tracked paths to file for later removal
                if test (count $added_paths) -gt 0
                    for p in $added_paths
                        echo $p >> $paths_file
                    end
                end

                # Show summary of what was loaded
                set_color green
                echo "✅ Loaded environment from $env_file"

                if test (count $set_variables) -gt 0
                    set_color cyan
                    echo "  Variables set: $set_variables"
                end

                if test (count $added_paths) -gt 0
                    set_color cyan
                    echo "  Paths added: $added_paths"
                end

                set_color normal
            end
        else
            set_color red
            echo "❌ File not found: $env_file"
            set_color normal
        end
    end
end
