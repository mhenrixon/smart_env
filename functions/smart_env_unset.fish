function smart_env_unset --description "Unset environment variables for the current directory"
    set -l storage_dir ~/.config/smart_env
    set -l current_dir $PWD
    
    # Look for all tracking files
    for dir_file in $storage_dir/variables/*.dir
        if test -f $dir_file
            set -l tracked_dir (cat $dir_file)
            
            # If we're not in this tracked directory anymore, unset its variables
            if test "$tracked_dir" != "$current_dir"
                set -l vars_file (string replace ".dir" ".vars" $dir_file)
                
                if test -f $vars_file
                    set_color yellow
                    echo "Unsetting environment variables from $tracked_dir"
                    set_color normal
                    
                    for var_name in (cat $vars_file)
                        set -e $var_name
                    end
                end
            end
        end
    end
end
