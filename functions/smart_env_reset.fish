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
                    # Skip PATH as we're using fish_add_path instead
                    if test "$var_name" != PATH
                        set -e $var_name
                    end
                end
            end
        end
        
        rm -rf $storage_dir
        mkdir -p $storage_dir/cache
        mkdir -p $storage_dir/variables
        set_color green
        echo "✅ All environment file approvals have been reset and variables unset"
        set_color normal
    else
        set_color yellow
        echo "❌ Operation cancelled"
        set_color normal
    end
end
