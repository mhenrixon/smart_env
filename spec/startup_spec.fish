# Tests for smart_env startup behavior
# These tests verify that the shell initialization properly handles
# inherited environments from iTerm2 split panes and directory changes

set -g __smart_env_pkg_dir (realpath (status dirname)/..)

function describe_bundler_cleanup
    function before_each
        # Source the function
        source $__smart_env_pkg_dir/functions/__smart_env_bundler_cleanup.fish
    end

    function after_each
        # Clean up any test variables
        set -e BUNDLE_GEMFILE
        set -e BUNDLE_PATH
        set -e BUNDLE_BIN
        set -e RUBYOPT
        set -e RUBYLIB
        set -e GEM_HOME
    end

    function it_clears_bundler_environment_variables
        # Simulate inherited bundler environment
        set -gx BUNDLE_GEMFILE /old/project/Gemfile
        set -gx BUNDLE_PATH "/old/project/.bundle"
        set -gx RUBYOPT -rbundler/setup

        # Run cleanup
        __smart_env_bundler_cleanup

        # Verify bundler variables are cleared (empty string means not set)
        assert -z "$BUNDLE_GEMFILE"
        assert -z "$BUNDLE_PATH"
        assert -z "$RUBYOPT"
    end

    function it_preserves_gem_home
        # Set up GEM_HOME (managed by chruby, should not be cleared by bundler cleanup)
        set -gx GEM_HOME "/Users/test/.gem/ruby/3.4.7"

        # Run bundler cleanup
        __smart_env_bundler_cleanup

        # GEM_HOME should still be set (bundler cleanup is chruby-safe)
        assert -n "$GEM_HOME"
        assert "$GEM_HOME" = "/Users/test/.gem/ruby/3.4.7"
    end

    function it_clears_all_bundle_vars
        # Set all bundler variables
        set -gx BUNDLE_GEMFILE /test/Gemfile
        set -gx BUNDLE_PATH "/test/.bundle"
        set -gx BUNDLE_BIN "/test/.bundle/bin"
        set -gx RUBYLIB /some/rubylib

        # Run cleanup
        __smart_env_bundler_cleanup

        # All should be cleared
        assert -z "$BUNDLE_GEMFILE"
        assert -z "$BUNDLE_PATH"
        assert -z "$BUNDLE_BIN"
        assert -z "$RUBYLIB"
    end
end

function describe_chruby_reset_mock
    function before_each
        mock_chruby_reset
    end

    function after_each
        set -e GEM_HOME
        set -e GEM_PATH
        set -e RUBY_ROOT
        set -e RUBY_VERSION
        set -e RUBY_ENGINE
        set -e GEM_ROOT
        set -e RUBYOPT
    end

    function it_clears_ruby_environment
        # Set up Ruby environment (simulating inherited state)
        set -gx GEM_HOME "/old/.gem/ruby/3.4.7"
        set -gx GEM_PATH "/old/.gem/ruby/3.4.7:/system/gems"
        set -gx RUBY_ROOT "/old/.rubies/ruby-3.4.7"
        set -gx RUBY_VERSION "3.4.7"

        # Run reset
        chruby_reset

        # Verify all cleared
        assert -z "$GEM_HOME"
        assert -z "$GEM_PATH"
        assert -z "$RUBY_ROOT"
        assert -z "$RUBY_VERSION"
    end
end

function describe_path_helper
    function it_detects_path_contains
        set -l test_path /usr/bin /test/bin /usr/local/bin

        # Test using contains directly
        set -l result 0
        if contains /test/bin $test_path
            set result 1
        end
        assert $result = 1

        set -l result2 0
        if contains /nonexistent/bin $test_path
            set result2 1
        end
        assert $result2 = 0
    end
end

function describe_function_existence
    function before_each
        source $__smart_env_pkg_dir/functions/smart_env.fish 2>/dev/null
        source $__smart_env_pkg_dir/functions/smart_env_unset.fish 2>/dev/null
        source $__smart_env_pkg_dir/functions/__smart_env_bundler_cleanup.fish 2>/dev/null
    end

    function it_has_smart_env_function
        set -l result 0
        if functions -q smart_env
            set result 1
        end
        assert $result = 1
    end

    function it_has_smart_env_unset_function
        set -l result 0
        if functions -q smart_env_unset
            set result 1
        end
        assert $result = 1
    end

    function it_has_bundler_cleanup_function
        set -l result 0
        if functions -q __smart_env_bundler_cleanup
            set result 1
        end
        assert $result = 1
    end
end
