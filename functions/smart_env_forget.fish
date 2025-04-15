function smart_env_forget --description "Forget an approved environment file"
    set -l storage_dir ~/.config/smart_env
    
    if test (count $argv) -eq 0
        set_color red
        echo "Please specify a file path to forget"
        set_color normal
        return
    end
    
    for env_file in $argv
        set -l abs_path (realpath $env_file)
        set -l hash_file $storage_dir/(echo $abs_path | string replace -a / _ | string replace -a : _).hash
        set -l cache_file $storage_dir/cache/(echo $abs_path | string replace -a / _ | string replace -a : _).env
        set -l vars_file $storage_dir/variables/(echo $abs_path | string replace -a / _ | string replace -a : _).vars
        set -l dir_file $storage_dir/variables/(echo $abs_path | string replace -a / _ | string replace -a : _).dir
        
        # Unset any environment variables from this file
        if test -f $vars_file
            for var_name in (cat $vars_file)
                set -e $var_name
            end
            rm $vars_file
        end
        
        # Clean up tracking files
        if test -f $hash_file
            rm $hash_file
        end
        if test -f $cache_file
            rm $cache_file
        end
        if test -f $dir_file
            rm $dir_file
        end
        
        set_color green
        echo "✅ Forgotten and unset: $env_file"
        set_color normal
    end
end
