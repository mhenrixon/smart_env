# Completions for smart_env

# Complete .env files in the current directory
complete -c smart_env -f -d "Smart environment loader with change detection"
complete -c smart_env -f -a "(find . -maxdepth 1 -name '*.env*' | string replace './' '')"
complete -c smart_env -f -a ".env" -d "Default environment file"
complete -c smart_env -f -a ".env.local" -d "Local environment overrides"
complete -c smart_env -f -a ".env.development" -d "Development environment"
complete -c smart_env -f -a ".env.test" -d "Test environment"
complete -c smart_env -f -a ".env.production" -d "Production environment"
