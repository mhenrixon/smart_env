# Completions for smart_env_switch command

# Complete with .env files in current directory
complete -c smart_env_switch -f -a '(__fish_complete_suffix .env)'
complete -c smart_env_switch -f -a '(__fish_complete_suffix .env.local)'
complete -c smart_env_switch -f -a '(__fish_complete_suffix .env.development)'
complete -c smart_env_switch -f -a '(__fish_complete_suffix .env.production)'
complete -c smart_env_switch -f -a '(__fish_complete_suffix .env.staging)'
complete -c smart_env_switch -f -a '(__fish_complete_suffix .env.test)'

# Also complete any file that matches *.env pattern
complete -c smart_env_switch -x -a '(ls *.env 2>/dev/null)'
complete -c smart_env_switch -x -a '(ls .env.* 2>/dev/null)'

# Add description
complete -c smart_env_switch -d 'Switch between different environment file contexts'