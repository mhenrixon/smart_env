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
                # Check if this file is marked as sticky (should persist across directories)
                set -l sticky_file (string replace ".dir" ".sticky" $dir_file)

                if test -f $sticky_file
                    # Skip unsetting sticky files
                    continue
                end

                set -l vars_file (string replace ".dir" ".vars" $dir_file)
                set -l paths_file (string replace ".dir" ".paths" $dir_file)

                if test -f $vars_file
                    set_color yellow
                    echo "📤 Unsetting environment variables from $tracked_dir"
                    set_color normal

                    # Track which variables we've unset
                    set -l unset_variables

                    # For each variable in vars_file, unset it
                    for var_name in (cat $vars_file)
                        # Skip PATH - we handle it separately via paths_file
                        if test "$var_name" = PATH
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

                # Remove tracked paths from fish_user_paths
                if test -f $paths_file
                    set -l removed_paths
                    for tracked_path in (cat $paths_file)
                        # Find and remove this path from fish_user_paths
                        set -l idx 1
                        for p in $fish_user_paths
                            if test "$p" = "$tracked_path"
                                set -e fish_user_paths[$idx]
                                set -a removed_paths $tracked_path
                                break
                            end
                            set idx (math $idx + 1)
                        end
                    end

                    if test (count $removed_paths) -gt 0
                        set_color green
                        echo "✅ Removed paths: $removed_paths"
                        set_color normal
                    end

                    rm -f $paths_file
                end
            end
        end
    end

    # Handle 1Password contexts similarly
    if test -d $storage_dir/1password
        for dir_file in $storage_dir/1password/*.dir
            # Skip if no match found
            if not test -f $dir_file
                continue
            end

            set -l tracked_dir (cat $dir_file)

            # If we're not in this tracked directory anymore, unset its variables
            if test "$tracked_dir" != "$current_dir"
                # Check if this file is marked as sticky (should persist across directories)
                set -l sticky_file (string replace ".dir" ".sticky" $dir_file)

                if test -f $sticky_file
                    # Skip unsetting sticky 1Password contexts
                    continue
                end

                set -l vars_file (string replace ".dir" ".vars" $dir_file)
                set -l meta_file (string replace ".dir" ".meta" $dir_file)

                if test -f $vars_file
                    set_color yellow
                    echo "📤 Unsetting 1Password variables from $tracked_dir"
                    set_color normal

                    # Track which variables we've unset
                    set -l unset_variables

                    # For each variable in vars_file, unset it
                    for var_name in (cat $vars_file)
                        # Handle PATH specially - don't touch it directly
                        if test "$var_name" = PATH
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
                        echo "✅ Unset 1Password variables: $unset_variables"
                        set_color normal
                    end

                    # Clean up tracking files
                    rm -f $vars_file
                    rm -f $dir_file
                    rm -f $meta_file
                end
            end
        end
    end
end
