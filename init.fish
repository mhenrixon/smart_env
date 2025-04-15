# Initialize the smart_env package

# You can use the following variables in this file:
# * $package       package name
# * $path          package path
# * $dependencies  package dependencies

function init -a path --on-event init_smart_env
    # Setup is now handled by the conf.d/smart_env.fish file
    # This ensures the package is initialized at shell startup
end

function uninstall --on-event uninstall_smart_env
    # Cleanup variables and reset
    if functions -q smart_env_reset
        smart_env_reset
    end
end
