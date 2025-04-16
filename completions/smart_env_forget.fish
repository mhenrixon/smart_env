# Completions for smart_env_forget

function __smart_env_approved_files
    set -l storage_dir ~/.config/smart_env
    if test -d $storage_dir
        for hash_file in $storage_dir/*.hash
            if test -f $hash_file
                set -l file_path (string replace -r "^$storage_dir/" "" (string replace -r '\.hash$' "" $hash_file))
                set -l file_path (string replace -a _ / $file_path)
                set -l file_path (string replace -r '_([a-zA-Z])_' '$1:' $file_path)
                echo $file_path
            end
        end
    end
end

complete -c smart_env_forget -f -d "Forget an approved environment file"
complete -c smart_env_forget -f -a "(__smart_env_approved_files)" -d "Previously approved environment file"
