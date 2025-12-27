#!/usr/bin/env fish
# Run smart_env tests

set -l script_dir (realpath (dirname (status -f)))

# Source fish-spec
set -l fish_spec_dir ~/.local/share/omf/pkg/fish-spec
source $fish_spec_dir/functions/fish-spec.fish
source $fish_spec_dir/functions/assert.fish
source $fish_spec_dir/functions/assert.error_message.fish
source $fish_spec_dir/functions/assert.expand_operator.fish
source $fish_spec_dir/basic_formatter.fish

# Change to package directory and run tests
cd $script_dir

echo "Running smart_env tests from: $script_dir"
echo ""

fish-spec
