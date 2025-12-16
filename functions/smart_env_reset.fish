function smart_env_reset --description "Reset all environment file approvals"
    set -l storage_dir ~/.config/smart_env

    if not test -d $storage_dir
        echo "No approved environment files to reset."
        return
    end

    read -l -P "Are you sure you want to forget all approved environment files? (y/n) " confirm

    if test "$confirm" = y -o "$confirm" = yes -o "$confirm" = Y
        # First unset all environment variables
        for vars_file in $storage_dir/variables/*.vars
            if test -f $vars_file
                for var_name in (cat $vars_file)
                    # Skip PATH as we handle it separately via paths_file
                    if test "$var_name" != PATH
                        set -e $var_name
                    end
                end
            end
        end

        # Remove all tracked paths from fish_user_paths
        for paths_file in $storage_dir/variables/*.paths
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
            end
        end

        rm -rf $storage_dir
        mkdir -p $storage_dir/cache
        mkdir -p $storage_dir/variables
        set_color green
        echo "✅ All environment file approvals have been reset, variables unset, and paths removed"
        set_color normal
    else
        set_color yellow
        echo "❌ Operation cancelled"
        set_color normal
    end
end
