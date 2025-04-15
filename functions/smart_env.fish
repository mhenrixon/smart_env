function smart_env --description "Smart environment loader with change detection"
    # Create storage directory if it doesn't exist
    set -l storage_dir ~/.config/smart_env
    mkdir -p $storage_dir/cache
    mkdir -p $storage_dir/variables

    # Process each env file
    for env_file in $argv
        if test -f $env_file
            set -l abs_path (realpath $env_file)
            set -l file_hash (md5sum $abs_path | string split ' ')[1]
            set -l hash_file $storage_dir/(echo $abs_path | string replace -a / _ | string replace -a : _).hash
            set -l cache_file $storage_dir/cache/(echo $abs_path | string replace -a / _ | string replace -a : _).env
            set -l vars_file $storage_dir/variables/(echo $abs_path | string replace -a / _ | string replace -a : _).vars
            
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
                        if type -q colordiff
                            colordiff $cache_file $abs_path
                        else if type -q diff
                            diff $cache_file $abs_path
                        else
                            echo "Install diff or colordiff for change visualization"
                        end
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
                # First unset any variables previously set by this file
                if test -f $vars_file
                    for var_name in (cat $vars_file)
                        set -e $var_name
                    end
                end
                
                # Clear tracked variables for this file
                echo -n "" > $vars_file
                
                # Load and track the new variables
                for line in (cat $abs_path | grep -v '^#' | grep -v '^\s*$')
                    set item (string split -m 1 '=' $line)
                    if test (count $item) -eq 2
                        set -gx $item[1] $item[2]
                        # Track this variable
                        echo $item[1] >> $vars_file
                    end
                end
                set_color green
                echo "✅ Loaded environment from $env_file"
                set_color normal
                
                # Store the current directory with this env file
                set -l dir_track_file $storage_dir/variables/(echo $abs_path | string replace -a / _ | string replace -a : _).dir
                echo $PWD > $dir_track_file
            end
        else
            set_color red
            echo "❌ File not found: $env_file"
            set_color normal
        end
    end
end