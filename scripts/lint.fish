#!/usr/bin/env fish
# Lint all fish scripts in the repository
#
# Usage:
#   ./scripts/lint.fish          # Check for issues
#   ./scripts/lint.fish --fix    # Auto-fix formatting issues

set -l script_dir (dirname (realpath (status -f)))
set -l root_dir (dirname $script_dir)
set -l fix_mode 0

# Parse arguments
for arg in $argv
    switch $arg
        case --fix -f
            set fix_mode 1
        case --help -h
            echo "Usage: lint.fish [--fix]"
            echo ""
            echo "Options:"
            echo "  --fix, -f    Auto-fix formatting issues"
            echo "  --help, -h   Show this help message"
            exit 0
    end
end

cd $root_dir

set -l syntax_errors 0
set -l format_errors 0
set -l files_fixed 0

echo "🔍 Linting fish scripts in $root_dir"
echo ""

# Find all fish files
set -l fish_files (find . -name "*.fish" -type f | grep -v ".git")

# Step 1: Syntax check
echo "📝 Step 1: Syntax check"
echo ------------------------

for file in $fish_files
    if not fish -n $file 2>/dev/null
        echo "  ❌ Syntax error in: $file"
        fish -n $file
        set syntax_errors (math $syntax_errors + 1)
    else
        echo "  ✓ $file"
    end
end

if test $syntax_errors -gt 0
    echo ""
    echo "❌ Found $syntax_errors file(s) with syntax errors"
    exit 1
end

echo ""
echo "✅ All files passed syntax check"
echo ""

# Step 2: Format check
echo "🎨 Step 2: Format check (fish_indent)"
echo --------------------------------------

for file in $fish_files
    set -l formatted (fish_indent < $file)
    set -l original (cat $file)

    if test "$formatted" != "$original"
        if test $fix_mode -eq 1
            fish_indent -w $file
            echo "  🔧 Fixed: $file"
            set files_fixed (math $files_fixed + 1)
        else
            echo "  ⚠️  Formatting issue: $file"
            set format_errors (math $format_errors + 1)
        end
    else
        echo "  ✓ $file"
    end
end

echo ""

if test $fix_mode -eq 1
    if test $files_fixed -gt 0
        echo "🔧 Fixed formatting in $files_fixed file(s)"
    else
        echo "✅ All files are properly formatted"
    end
    exit 0
end

if test $format_errors -gt 0
    echo "⚠️  Found $format_errors file(s) with formatting issues"
    echo ""
    echo "Run './scripts/lint.fish --fix' to auto-fix formatting issues"
    exit 1
end

echo "✅ All files are properly formatted"
echo ""
echo "🎉 All checks passed!"
