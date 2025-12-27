function smart_env_1password --description "Load environment variables from 1Password"
    set -l storage_dir ~/.config/smart_env
    mkdir -p $storage_dir/cache
    mkdir -p $storage_dir/variables
    mkdir -p $storage_dir/1password

    set -l sticky 0
    set -l vault ""
    set -l item ""
    set -l field_filter ""
    set -l context_name ""

    # Check if op CLI is installed
    if not type -q op
        set_color red
        echo "❌ 1Password CLI (op) is not installed"
        echo ""
        echo "Install it with:"
        echo "  brew install 1password-cli"
        echo ""
        echo "Or visit: https://developer.1password.com/docs/cli/get-started/"
        set_color normal
        return 1
    end

    # Parse arguments
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case -h --help
                echo "Usage: smart_env_1password [OPTIONS] ITEM"
                echo ""
                echo "Load environment variables from 1Password"
                echo ""
                echo "Options:"
                echo "  -v, --vault VAULT      Specify vault name (optional)"
                echo "  -f, --field FIELD      Only load specific field"
                echo "  -n, --name NAME        Set a custom context name"
                echo "  -s, --sticky           Keep loaded across directory changes"
                echo "  -h, --help             Show this help message"
                echo ""
                echo "Examples:"
                echo "  # Load all env vars from an item named 'production-secrets'"
                echo "  smart_env_1password production-secrets"
                echo ""
                echo "  # Load from a specific vault"
                echo "  smart_env_1password --vault MyVault my-secrets"
                echo ""
                echo "  # Load only a specific field"
                echo "  smart_env_1password --field DATABASE_URL my-secrets"
                echo ""
                echo "  # Load and keep sticky (persist across directories)"
                echo "  smart_env_1password --sticky production-secrets"
                echo ""
                echo "Note: You must be signed in to 1Password CLI (run 'op signin')"
                set_color normal
                return 0

            case -v --vault
                set i (math $i + 1)
                if test $i -le (count $argv)
                    set vault $argv[$i]
                else
                    set_color red
                    echo "❌ --vault requires a value"
                    set_color normal
                    return 1
                end

            case -f --field
                set i (math $i + 1)
                if test $i -le (count $argv)
                    set field_filter $argv[$i]
                else
                    set_color red
                    echo "❌ --field requires a value"
                    set_color normal
                    return 1
                end

            case -n --name
                set i (math $i + 1)
                if test $i -le (count $argv)
                    set context_name $argv[$i]
                else
                    set_color red
                    echo "❌ --name requires a value"
                    set_color normal
                    return 1
                end

            case -s --sticky
                set sticky 1

            case '*'
                if test -z "$item"
                    set item $argv[$i]
                else
                    set_color red
                    echo "❌ Multiple items specified. Only one item can be loaded at a time."
                    set_color normal
                    return 1
                end
        end
        set i (math $i + 1)
    end

    # Check if item was specified
    if test -z "$item"
        set_color red
        echo "❌ No item specified"
        echo "Usage: smart_env_1password [OPTIONS] ITEM"
        echo "Try 'smart_env_1password --help' for more information"
        set_color normal
        return 1
    end

    # Build op command
    set -l op_cmd op item get $item --format json

    if test -n "$vault"
        set -a op_cmd --vault $vault
    end

    # Set context name
    if test -z "$context_name"
        set context_name "1password:$item"
    end

    set_color cyan
    echo "🔐 Loading secrets from 1Password item: $item"
    set_color normal

    # Fetch the item from 1Password
    set -l json_output
    if not set json_output (eval $op_cmd 2>&1)
        set_color red
        echo "❌ Failed to fetch from 1Password"
        echo ""
        echo "Error: $json_output"
        echo ""
        echo "Make sure you're signed in with: op signin"
        set_color normal
        return 1
    end

    # Create a unique identifier for this 1Password source
    set -l source_id (echo "$context_name" | string replace -a ' ' '_' | string replace -a ':' '_' | string replace -a '/' '_')
    set -l vars_file $storage_dir/1password/$source_id.vars
    set -l dir_track_file $storage_dir/1password/$source_id.dir
    set -l sticky_file $storage_dir/1password/$source_id.sticky
    set -l meta_file $storage_dir/1password/$source_id.meta

    # Store metadata
    echo "source=1password" >$meta_file
    echo "item=$item" >>$meta_file
    if test -n "$vault"
        echo "vault=$vault" >>$meta_file
    end
    echo "loaded="(date -u +"%Y-%m-%dT%H:%M:%SZ") >>$meta_file

    # Track current directory
    echo $PWD >$dir_track_file

    # Clear existing vars file
    echo -n "" >$vars_file

    # Track loaded variables
    set -l loaded_vars
    set -l error_occurred 0

    # Parse JSON and extract fields
    # Look for fields in the item
    set -l fields (echo $json_output | op item get $item --fields label 2>/dev/null | string split \n)

    if test (count $fields) -eq 0
        # Try alternative approach - parse the JSON directly for env-like fields
        set_color yellow
        echo "⚠️  No labeled fields found. Trying to extract environment variables..."
        set_color normal

        # This is a fallback - you might need to adjust based on your 1Password structure
        # For now, we'll just notify the user
        set_color red
        echo "❌ Could not extract environment variables from this item"
        echo ""
        echo "Make sure the item has fields formatted as environment variables"
        echo "Each field should have a label (variable name) and value"
        set_color normal
        return 1
    end

    # Load each field
    for field_label in $fields
        # Skip if we're filtering and this isn't the field we want
        if test -n "$field_filter"; and test "$field_label" != "$field_filter"
            continue
        end

        # Get the field value
        set -l field_value (echo $json_output | op item get $item --fields $field_label 2>/dev/null)

        if test $status -eq 0; and test -n "$field_value"
            # Set the environment variable
            set -gx $field_label $field_value
            set -a loaded_vars $field_label

            # Track the variable
            echo $field_label >>$vars_file

            set_color green
            echo "  ✓ $field_label"
            set_color normal
        end
    end

    # Check if we loaded anything
    if test (count $loaded_vars) -eq 0
        set_color yellow
        echo "⚠️  No variables were loaded"
        set_color normal
        return 1
    end

    # Mark as sticky if requested
    if test $sticky -eq 1
        touch $sticky_file
        set_color cyan
        echo "📌 Marked as sticky (won't unload on directory change)"
        set_color normal
    end

    # Set the current context
    set -gx SMART_ENV_CURRENT "1password:$source_id"

    set_color green
    echo "✅ Loaded "(count $loaded_vars)" variable(s) from 1Password"
    set_color normal

    # Show loaded variables (names only, not values)
    set_color cyan
    echo "Variables loaded: $loaded_vars"
    set_color normal
end
