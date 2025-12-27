#!/usr/bin/env fish
# Setup script for chruby integration with smart_env
#
# This script ensures chruby is properly configured to work with smart_env,
# preventing Ruby environment "leaks" when opening new shells or switching directories.
#
# Usage:
#   fish ~/.config/omf/pkg/smart_env/scripts/setup_chruby.fish

set -l config_file ~/.config/fish/config.fish

echo "🔧 smart_env chruby Integration Setup"
echo "======================================"
echo ""

# Detect chruby installation path
set -l chruby_base ""
if test -d /opt/homebrew/opt/chruby-fish/share/fish
    set chruby_base /opt/homebrew/opt/chruby-fish/share/fish
else if test -d /usr/local/opt/chruby-fish/share/fish
    set chruby_base /usr/local/opt/chruby-fish/share/fish
else if test -d /usr/local/share/fish/vendor_functions.d
    # Check if chruby files exist in standard location
    if test -f /usr/local/share/fish/vendor_functions.d/chruby.fish
        set chruby_base /usr/local/share/fish
    end
else if test -d /usr/share/fish/vendor_functions.d
    if test -f /usr/share/fish/vendor_functions.d/chruby.fish
        set chruby_base /usr/share/fish
    end
end

if test -z "$chruby_base"
    echo "❌ chruby-fish not found!"
    echo ""
    echo "Please install chruby-fish first:"
    echo ""
    echo "  macOS (Homebrew):"
    echo "    brew install chruby-fish"
    echo ""
    echo "  Linux:"
    echo "    See https://github.com/JeanMertz/chruby-fish"
    echo ""
    exit 1
end

echo "✓ Found chruby-fish at: $chruby_base"
echo ""

# Check required files exist
set -l required_files \
    "$chruby_base/vendor_functions.d/chruby_reset.fish" \
    "$chruby_base/vendor_functions.d/chruby_use.fish" \
    "$chruby_base/vendor_functions.d/chruby.fish" \
    "$chruby_base/vendor_conf.d/chruby_auto.fish"

set -l missing_files
for f in $required_files
    if not test -f $f
        set -a missing_files $f
    end
end

if test (count $missing_files) -gt 0
    echo "❌ Missing required chruby files:"
    for f in $missing_files
        echo "   - $f"
    end
    exit 1
end

echo "✓ All required chruby files found"
echo ""

# Check for broken custom chruby_use
set -l custom_chruby_use ~/.config/fish/functions/chruby_use.fish
if test -f $custom_chruby_use
    echo "⚠️  Found custom chruby_use.fish"
    echo "   Location: $custom_chruby_use"
    echo ""

    # Check if it contains the broken clean_path call
    if grep -q clean_path $custom_chruby_use
        echo "   This file contains a call to 'clean_path' which doesn't exist."
        echo ""
        read -l -P "   Remove this broken file? [y/N] " confirm
        if test "$confirm" = y -o "$confirm" = Y
            rm $custom_chruby_use
            echo "   ✓ Removed $custom_chruby_use"
        else
            echo "   ⚠️  Skipped. You may need to fix or remove this file manually."
        end
    else
        echo "   This file may override the vendor chruby_use."
        read -l -P "   Remove it to use the vendor version? [y/N] " confirm
        if test "$confirm" = y -o "$confirm" = Y
            rm $custom_chruby_use
            echo "   ✓ Removed $custom_chruby_use"
        end
    end
    echo ""
end

# Check current config.fish
echo "📝 Checking $config_file..."
echo ""

if not test -f $config_file
    echo "   Creating new config.fish..."
    mkdir -p (dirname $config_file)
    touch $config_file
end

# Build the chruby configuration block
set -l chruby_config "# chruby configuration (managed by smart_env)
# Source all chruby functions in correct order
source $chruby_base/vendor_functions.d/chruby_reset.fish
source $chruby_base/vendor_functions.d/chruby_use.fish
source $chruby_base/vendor_functions.d/chruby.fish
source $chruby_base/vendor_conf.d/chruby_auto.fish"

# Check if chruby is already configured
if grep -q "chruby_reset.fish" $config_file
    echo "✓ chruby_reset.fish already sourced in config.fish"

    # Verify all files are sourced
    set -l all_sourced 1
    if not grep -q "chruby_use.fish" $config_file
        set all_sourced 0
    end

    if test $all_sourced -eq 1
        echo "✓ All chruby functions appear to be sourced"
        echo ""
        echo "🎉 chruby integration is already configured!"
        echo ""
        echo "If you're still having issues, try:"
        echo "  1. Open a new terminal tab/window"
        echo "  2. Run: chruby"
        echo "  3. Verify your Ruby: ruby --version"
        exit 0
    end
end

# Check for old-style chruby configuration (missing chruby_reset)
if grep -q "chruby.fish" $config_file
    if not grep -q "chruby_reset.fish" $config_file
        echo "⚠️  Found incomplete chruby configuration"
        echo "   chruby.fish is sourced but chruby_reset.fish is missing"
        echo ""
        echo "   This can cause Ruby environment issues in split panes."
        echo ""
        read -l -P "   Update to complete configuration? [Y/n] " confirm
        if test "$confirm" != n -a "$confirm" != N
            # Create backup
            cp $config_file "$config_file.backup"
            echo "   ✓ Backup created: $config_file.backup"

            # Replace old chruby config with new
            # This is a simplified approach - just add the missing sources before chruby.fish
            set -l tmpfile (mktemp)

            # Read the file and insert missing sources
            set -l in_chruby_section 0
            set -l added_sources 0

            while read -l line
                # Check if this is a chruby source line
                if string match -q "*chruby*.fish*" $line
                    if test $added_sources -eq 0
                        # Add all sources in correct order (if not already present)
                        if not grep -q "chruby_reset.fish" $config_file
                            echo "source $chruby_base/vendor_functions.d/chruby_reset.fish"
                        end
                        if not grep -q "chruby_use.fish" $config_file
                            echo "source $chruby_base/vendor_functions.d/chruby_use.fish"
                        end
                        set added_sources 1
                    end
                end
                echo $line
            end <$config_file >$tmpfile

            mv $tmpfile $config_file
            echo "   ✓ Updated config.fish with complete chruby configuration"
        end
    end
else
    # No chruby config found, add it
    echo "   No chruby configuration found in config.fish"
    echo ""
    read -l -P "   Add chruby configuration? [Y/n] " confirm
    if test "$confirm" != n -a "$confirm" != N
        echo "" >>$config_file
        echo $chruby_config >>$config_file
        echo "" >>$config_file

        # Ask about default Ruby
        echo ""
        echo "   Available Ruby versions:"
        if test -d ~/.rubies
            for ruby in ~/.rubies/*
                echo "     - "(basename $ruby)
            end
        end

        read -l -P "   Set default Ruby version (e.g., ruby-3.4.7) or press Enter to skip: " ruby_version
        if test -n "$ruby_version"
            echo "chruby $ruby_version" >>$config_file
            echo "   ✓ Added: chruby $ruby_version"
        end

        echo ""
        echo "   ✓ Added chruby configuration to config.fish"
    end
end

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Open a new terminal tab/window"
echo "  2. Run: chruby"
echo "  3. Verify your Ruby: ruby --version"
echo ""
echo "If you still see gem errors, run:"
echo "  chruby_reset && chruby ruby-3.4.7  # or your version"
