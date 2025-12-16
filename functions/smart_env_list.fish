function smart_env_list --description "List all approved environment files and contexts"
    set -l storage_dir ~/.config/smart_env

    # Show current context
    if set -q SMART_ENV_CURRENT
        set_color cyan
        echo "📍 Current context:"
        set_color green
        if string match -q "1password:*" $SMART_ENV_CURRENT
            echo "  → "(string replace "1password:" "" $SMART_ENV_CURRENT)" (1Password)"
        else
            echo "  → $SMART_ENV_CURRENT"
        end
        set_color normal
        echo ""
    end

    # List approved .env files
    set -l has_env_files 0
    if test -d $storage_dir
        for hash_file in $storage_dir/*.hash
            if not test -f $hash_file
                continue
            end
            set has_env_files 1
            break
        end
    end

    if test $has_env_files -eq 1
        set_color cyan
        echo "📄 Approved environment files:"
        set_color normal

        for hash_file in $storage_dir/*.hash
            if not test -f $hash_file
                continue
            end

            set -l file_path (string replace -r "^$storage_dir/" "" (string replace -r '\.hash$' "" $hash_file))
            set -l file_path (string replace -a _ / $file_path)
            set -l file_path (string replace -r '_([a-zA-Z])_' '$1:' $file_path)

            # Check if sticky
            set -l base_name (basename $hash_file .hash)
            set -l vars_file $storage_dir/variables/$base_name.vars
            set -l sticky_file $storage_dir/variables/$base_name.sticky

            if test -f $sticky_file
                echo "  • $file_path 📌 (sticky)"
            else if test -f $vars_file
                echo "  • $file_path ✓ (loaded)"
            else
                echo "  • $file_path"
            end
        end
        echo ""
    end

    # List 1Password contexts
    set -l has_1password 0
    if test -d $storage_dir/1password
        for meta_file in $storage_dir/1password/*.meta
            if not test -f $meta_file
                continue
            end
            set has_1password 1
            break
        end
    end

    if test $has_1password -eq 1
        set_color cyan
        echo "🔐 1Password contexts:"
        set_color normal

        for meta_file in $storage_dir/1password/*.meta
            if not test -f $meta_file
                continue
            end

            set -l base_name (basename $meta_file .meta)
            set -l item_name (grep '^item=' $meta_file | string replace 'item=' '')
            set -l vault_name (grep '^vault=' $meta_file | string replace 'vault=' '')
            set -l loaded_date (grep '^loaded=' $meta_file | string replace 'loaded=' '')
            set -l vars_file $storage_dir/1password/$base_name.vars
            set -l sticky_file $storage_dir/1password/$base_name.sticky

            set -l display_name $item_name
            if test -n "$vault_name"
                set display_name "$vault_name/$item_name"
            end

            if test -f $sticky_file
                echo "  • $display_name 📌 (sticky)"
            else if test -f $vars_file
                echo "  • $display_name ✓ (loaded)"
            else
                echo "  • $display_name"
            end

            if test -n "$loaded_date"
                set_color blue
                echo "    Last loaded: $loaded_date"
                set_color normal
            end
        end
        echo ""
    end

    # If nothing is loaded
    if test $has_env_files -eq 0; and test $has_1password -eq 0
        set_color yellow
        echo "No approved environment files or contexts."
        set_color normal
    end
end
