function smart_env_unset --description "Unset environment variables for the current directory"
    set -l storage_dir ~/.config/smart_env
    set -l current_dir $PWD

    # Look for all tracking files - handle if directory doesn't exist yet
    if test -d $storage_dir/variables
        for dir_file in $storage_dir/variables/*.dir
            # Skip if no match found
            if not test -f $dir_file
                continue
            end

            set -l tracked_dir (cat $dir_file)

            # If we're not in this tracked directory anymore, unset its variables
            if test "$tracked_dir" != "$current_dir"
                set -l vars_file (string replace ".dir" ".vars" $dir_file)

                if test -f $vars_file
                    set_color yellow
                    echo "📤 Unsetting environment variables from $tracked_dir"
                    set_color normal

                    # Track which variables we've unset
                    set -l unset_variables
                    
                    # For each variable in vars_file, unset it
                    for var_name in (cat $vars_file)
                        # Handle PATH specially - don't touch it directly
                        if test "$var_name" = "PATH"
                            continue
                        end

                        # Unset the variable in all scopes
                        set -e $var_name
                        set -e -U $var_name
                        set -a unset_variables $var_name
                    end
                    
                    # Show summary of what was unset
                    if test (count $unset_variables) -gt 0
                        set_color green
                        echo "✅ Unset variables: $unset_variables"
                        set_color normal
                    end

                    # Clean up tracking files
                    rm -f $vars_file
                    rm -f $dir_file
                end
            end
        end
    end
end
