#!/usr/bin/env fish
# Run the smart_env test suite
#
# Usage:
#   ./scripts/test.fish

set -l script_dir (dirname (realpath (status -f)))
set -l root_dir (dirname $script_dir)

cd $root_dir

echo "🧪 Running smart_env tests"
echo "=========================="
echo ""

# Check if fish-spec is installed
set -l fish_spec_dir ~/.local/share/omf/pkg/fish-spec

if not test -d $fish_spec_dir
    echo "❌ fish-spec not found at $fish_spec_dir"
    echo ""
    echo "Install fish-spec with:"
    echo "  mkdir -p ~/.local/share/omf/pkg"
    echo "  git clone https://github.com/oh-my-fish/fish-spec.git ~/.local/share/omf/pkg/fish-spec"
    exit 1
end

# Source fish-spec
source $fish_spec_dir/functions/fish-spec.fish
source $fish_spec_dir/functions/assert.fish
source $fish_spec_dir/functions/assert.error_message.fish
source $fish_spec_dir/functions/assert.expand_operator.fish
source $fish_spec_dir/basic_formatter.fish

# Run tests
set -l start_time (date +%s)

fish-spec
set -l test_status $status

set -l end_time (date +%s)
set -l duration (math $end_time - $start_time)

echo ""
echo "⏱️  Tests completed in {$duration}s"

if test $test_status -eq 0
    echo "✅ All tests passed!"
else
    echo "❌ Some tests failed"
end

exit $test_status
