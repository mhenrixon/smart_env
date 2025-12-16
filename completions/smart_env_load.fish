# Completions for smart_env_load command

# Options
complete -c smart_env_load -s s -l sticky -d 'Keep loaded even when changing directories'
complete -c smart_env_load -s r -l replace -d 'Replace current context instead of adding to it'
complete -c smart_env_load -s h -l help -d 'Show help message'

# Complete with .env files in current directory
complete -c smart_env_load -f -a '(__fish_complete_suffix .env)'
complete -c smart_env_load -f -a '(__fish_complete_suffix .env.local)'
complete -c smart_env_load -f -a '(__fish_complete_suffix .env.development)'
complete -c smart_env_load -f -a '(__fish_complete_suffix .env.production)'
complete -c smart_env_load -f -a '(__fish_complete_suffix .env.staging)'
complete -c smart_env_load -f -a '(__fish_complete_suffix .env.test)'
complete -c smart_env_load -f -a '(__fish_complete_suffix .env.demo)'

# Also complete any file that matches *.env pattern
complete -c smart_env_load -x -a '(ls *.env 2>/dev/null)'
complete -c smart_env_load -x -a '(ls .env.* 2>/dev/null)'

# Add description
complete -c smart_env_load -d 'Explicitly load an environment file and set it as current context'