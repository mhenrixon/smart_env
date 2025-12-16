function smart_env_forget --description "Forget an approved environment file"
    set -l storage_dir ~/.config/smart_env

    if test (count $argv) -eq 0
        set_color red
        echo "Please specify a file path to forget"
        set_color normal
        return
    end

    for env_file in $argv
        set -l abs_path (realpath $env_file)
        set -l hash_file $storage_dir/(echo $abs_path | string replace -a / _ | string replace -a : _).hash
        set -l cache_file $storage_dir/cache/(echo $abs_path | string replace -a / _ | string replace -a : _).env
        set -l vars_file $storage_dir/variables/(echo $abs_path | string replace -a / _ | string replace -a : _).vars
        set -l paths_file $storage_dir/variables/(echo $abs_path | string replace -a / _ | string replace -a : _).paths
        set -l dir_file $storage_dir/variables/(echo $abs_path | string replace -a / _ | string replace -a : _).dir
        set -l sticky_file $storage_dir/variables/(echo $abs_path | string replace -a / _ | string replace -a : _).sticky

        # Unset any environment variables from this file
        if test -f $vars_file
            for var_name in (cat $vars_file)
                # Skip PATH as we handle it separately via paths_file
                if test "$var_name" != PATH
                    set -e $var_name
                end
            end
            rm $vars_file
        end

        # Remove tracked paths from fish_user_paths
        if test -f $paths_file
            for tracked_path in (cat $paths_file)
                set -l idx 1
                for p in $fish_user_paths
                    if test "$p" = "$tracked_path"
                        set -e fish_user_paths[$idx]
                        break
                    end
                    set idx (math $idx + 1)
                end
            end
            rm $paths_file
        end

        # Clean up tracking files
        if test -f $hash_file
            rm $hash_file
        end
        if test -f $cache_file
            rm $cache_file
        end
        if test -f $dir_file
            rm $dir_file
        end
        if test -f $sticky_file
            rm $sticky_file
        end

        # Clear current context if we're forgetting it
        if set -q SMART_ENV_CURRENT; and test "$SMART_ENV_CURRENT" = "$abs_path"
            set -e SMART_ENV_CURRENT
            set_color yellow
            echo "📤 Cleared current context"
            set_color normal
        end

        set_color green
        echo "✅ Forgotten and unset: $env_file"
        set_color normal
    end
end
