# Completions for smart_env_1password command

# Options
complete -c smart_env_1password -s v -l vault -d 'Specify vault name' -x
complete -c smart_env_1password -s f -l field -d 'Only load specific field' -x
complete -c smart_env_1password -s n -l name -d 'Set a custom context name' -x
complete -c smart_env_1password -s s -l sticky -d 'Keep loaded across directory changes'
complete -c smart_env_1password -s h -l help -d 'Show help message'

# Complete vault names (if op is available)
complete -c smart_env_1password -l vault -f -a '(op vault list --format=json 2>/dev/null | jq -r ".[].name" 2>/dev/null)'

# Complete item names (if op is available)
complete -c smart_env_1password -f -a '(op item list --format=json 2>/dev/null | jq -r ".[].title" 2>/dev/null)'

# Add description
complete -c smart_env_1password -d 'Load environment variables from 1Password'