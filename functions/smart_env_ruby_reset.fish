function smart_env_ruby_reset --description "Manually reset Ruby/Bundler environment and reload mise for current directory"
    # First, clean up any stale Bundler environment variables
    # NOTE: Use bundler_cleanup which is chruby-safe (doesn't clear GEM_HOME, etc.)
    if functions -q __smart_env_bundler_cleanup
        __smart_env_bundler_cleanup
    end

    # Re-apply chruby for the current directory
    if functions -q chruby_auto
        chruby_auto
    end

    # Force mise to re-evaluate the current directory (for non-Ruby tools)
    if command -q mise
        set_color cyan
        echo "🔄 Reloading mise environment for $PWD"
        set_color normal

        # Deactivate and reactivate mise to get fresh environment
        if functions -q __mise_env_eval
            __mise_env_eval
        else
            # Fallback: manually trigger mise hook
            eval (mise hook-env -s fish 2>/dev/null)
        end

        set_color green
        echo "✅ mise environment reloaded"
        set_color normal
    end

    # Show current Ruby state
    echo ""
    set_color cyan
    echo "Current Ruby environment:"
    set_color normal
    echo "  Ruby:    "(which ruby 2>/dev/null || echo "not found")
    echo "  Version: "(ruby --version 2>/dev/null || echo "n/a")
    echo "  Bundler: "(bundle --version 2>/dev/null || echo "not found")

    # Show any remaining Ruby-related env vars
    set -l ruby_vars (env | grep -iE '^(RUBY|GEM|BUNDLE|RBENV|RVM|CHRUBY)' | head -10)
    if test (count $ruby_vars) -gt 0
        echo ""
        echo "  Active Ruby env vars:"
        for var in $ruby_vars
            echo "    $var"
        end
    end
end
