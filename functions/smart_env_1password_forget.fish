function smart_env_1password_forget --description "Forget and unload a 1Password environment context"
    set -l storage_dir ~/.config/smart_env

    if test (count $argv) -eq 0
        # List available 1Password contexts
        set_color yellow
        echo "Available 1Password contexts to forget:"
        set_color normal

        if test -d $storage_dir/1password
            set -l found_any 0
            for meta_file in $storage_dir/1password/*.meta
                if not test -f $meta_file
                    continue
                end
                set found_any 1

                set -l base_name (basename $meta_file .meta)
                set -l item_name (grep '^item=' $meta_file | string replace 'item=' '')
                set -l vault_name (grep '^vault=' $meta_file | string replace 'vault=' '')

                set -l display_name $item_name
                if test -n "$vault_name"
                    set display_name "$vault_name/$item_name"
                end

                echo "  • $display_name"
            end

            if test $found_any -eq 0
                set_color yellow
                echo "  (none found)"
                set_color normal
            end
        else
            set_color yellow
            echo "  (none found)"
            set_color normal
        end

        echo ""
        echo "Usage: smart_env_1password_forget ITEM_NAME"
        echo "   or: smart_env_1password_forget VAULT/ITEM_NAME"
        return 0
    end

    # Process each specified context
    for context_arg in $argv
        set -l found 0

        # Search for matching 1Password contexts
        if test -d $storage_dir/1password
            for meta_file in $storage_dir/1password/*.meta
                if not test -f $meta_file
                    continue
                end

                set -l base_name (basename $meta_file .meta)
                set -l item_name (grep '^item=' $meta_file | string replace 'item=' '')
                set -l vault_name (grep '^vault=' $meta_file | string replace 'vault=' '')

                # Check if this matches what we're looking for
                set -l matches 0
                if test "$context_arg" = "$item_name"
                    set matches 1
                else if test -n "$vault_name"; and test "$context_arg" = "$vault_name/$item_name"
                    set matches 1
                else if test "$context_arg" = "$base_name"
                    set matches 1
                end

                if test $matches -eq 1
                    set found 1

                    set -l vars_file $storage_dir/1password/$base_name.vars
                    set -l dir_file $storage_dir/1password/$base_name.dir
                    set -l sticky_file $storage_dir/1password/$base_name.sticky

                    # Unset any environment variables from this context
                    if test -f $vars_file
                        set -l unset_vars
                        for var_name in (cat $vars_file)
                            # Skip PATH as we don't directly manage it
                            if test "$var_name" != PATH
                                set -e $var_name
                                set -e -U $var_name
                                set -a unset_vars $var_name
                            end
                        end

                        if test (count $unset_vars) -gt 0
                            set_color cyan
                            echo "📤 Unset variables: $unset_vars"
                            set_color normal
                        end

                        rm -f $vars_file
                    end

                    # Clean up tracking files
                    rm -f $meta_file
                    rm -f $dir_file
                    rm -f $sticky_file

                    # Clear current context if we're forgetting it
                    if set -q SMART_ENV_CURRENT
                        if string match -q "*$base_name*" $SMART_ENV_CURRENT
                            set -e SMART_ENV_CURRENT
                            set_color yellow
                            echo "📤 Cleared current context"
                            set_color normal
                        end
                    end

                    set_color green
                    set -l display_name $item_name
                    if test -n "$vault_name"
                        set display_name "$vault_name/$item_name"
                    end
                    echo "✅ Forgotten 1Password context: $display_name"
                    set_color normal
                end
            end
        end

        if test $found -eq 0
            set_color red
            echo "❌ 1Password context not found: $context_arg"
            set_color normal
        end
    end
end