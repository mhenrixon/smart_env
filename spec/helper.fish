# Test helper functions for smart_env

# Create a temporary directory for test isolation
function setup_test_env
    set -g __test_tmpdir (mktemp -d)
    set -g __test_original_pwd $PWD
    set -g __test_original_gem_home $GEM_HOME
    set -g __test_original_gem_path $GEM_PATH
    set -g __test_original_ruby_root $RUBY_ROOT
    set -g __test_original_ruby_version $RUBY_VERSION
    set -g __test_original_path $PATH

    # Create test project directories
    mkdir -p "$__test_tmpdir/project1"
    mkdir -p "$__test_tmpdir/project2"
    mkdir -p "$__test_tmpdir/project1/bin"
    mkdir -p "$__test_tmpdir/project2/bin"

    # Create .ruby-version files (use installed Ruby version)
    echo "3.4.7" > "$__test_tmpdir/project1/.ruby-version"
    echo "3.4.7" > "$__test_tmpdir/project2/.ruby-version"

    # Note: We don't create .env files here to avoid interactive prompts during tests
end

# Clean up test environment
function teardown_test_env
    # Restore original environment
    if set -q __test_original_pwd
        cd $__test_original_pwd
    end

    if set -q __test_original_gem_home; and test -n "$__test_original_gem_home"
        set -gx GEM_HOME $__test_original_gem_home
    else
        set -e GEM_HOME
    end

    if set -q __test_original_gem_path; and test -n "$__test_original_gem_path"
        set -gx GEM_PATH $__test_original_gem_path
    else
        set -e GEM_PATH
    end

    if set -q __test_original_ruby_root; and test -n "$__test_original_ruby_root"
        set -gx RUBY_ROOT $__test_original_ruby_root
    else
        set -e RUBY_ROOT
    end

    if set -q __test_original_ruby_version; and test -n "$__test_original_ruby_version"
        set -gx RUBY_VERSION $__test_original_ruby_version
    else
        set -e RUBY_VERSION
    end

    if set -q __test_original_path
        set -gx PATH $__test_original_path
    end

    # Clean up temp directory
    if set -q __test_tmpdir; and test -d "$__test_tmpdir"
        rm -rf "$__test_tmpdir"
    end

    # Clean up test variables
    set -e __test_tmpdir
    set -e __test_original_pwd
    set -e __test_original_gem_home
    set -e __test_original_gem_path
    set -e __test_original_ruby_root
    set -e __test_original_ruby_version
    set -e __test_original_path
end

# Simulate inherited environment from another project (like iTerm2 split pane)
function simulate_inherited_env --argument-names project_path
    set -gx GEM_HOME "$project_path/.gem/ruby/3.4.7"
    set -gx GEM_PATH "$project_path/.gem/ruby/3.4.7:/some/old/gem/path"
    set -gx RUBY_ROOT "/Users/mhenrixon/.rubies/ruby-3.4.7"
    set -gx RUBY_VERSION "3.4.7"
    set -gx PATH "$project_path/bin" "$GEM_HOME/bin" $PATH
    set -gx BUNDLE_GEMFILE "$project_path/Gemfile"
end

# Mock chruby_reset for testing
function mock_chruby_reset
    function chruby_reset
        set -e GEM_HOME
        set -e GEM_PATH
        set -e RUBY_ROOT
        set -e RUBY_VERSION
        set -e RUBY_ENGINE
        set -e GEM_ROOT
        set -e RUBYOPT
    end
end

# Check if a path exists in PATH
function path_contains --argument-names check_path
    contains -- $check_path $PATH
end
