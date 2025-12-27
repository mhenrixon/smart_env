function __smart_env_cleanup --description "Clean up environment variables when leaving a directory"
    # Get list of all environment variables 
    set -l current_vars (env | cut -d= -f1)

    # List of variables that should never be unset
    set -l protected_vars PATH MANPATH INFOPATH USER HOME SHELL TERM EDITOR VISUAL PAGER LANG LC_ALL DISPLAY LOGNAME USERNAME MAIL HOSTNAME HOSTTYPE VENDOR OSTYPE MACHTYPE SSH_AUTH_SOCK TERM_PROGRAM PWD OLDPWD SHLVL _ fish_history fish_greeting fish_key_bindings

    # Also add common fish_ prefixed variables to the protected list
    for var in $current_vars
        if string match -q "fish_*" $var
            set -a protected_vars $var
        end
    end

    # Unset all non-protected variables
    for var in $current_vars
        set is_protected 0
        for pvar in $protected_vars
            if test "$var" = "$pvar"
                set is_protected 1
                break
            end
        end

        # If not protected and not starting with special characters (fish internal vars)
        if test $is_protected -eq 0; and not string match -q "[_.]*" $var
            set -e $var
        end
    end

    # Return success to ensure the command doesn't fail
    return 0
end
