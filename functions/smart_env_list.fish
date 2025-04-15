function smart_env_list --description "List all approved environment files"
    set -l storage_dir ~/.config/smart_env
    
    if not test -d $storage_dir
        echo "No approved environment files."
        return
    end
    
    echo "Approved environment files:"
    
    for hash_file in $storage_dir/*.hash
        set -l file_path (string replace -r "^$storage_dir/" "" (string replace -r '\.hash$' "" $hash_file))
        set -l file_path (string replace -a _ / $file_path)
        set -l file_path (string replace -r '_([a-zA-Z])_' '$1:' $file_path)
        echo "- $file_path"
    end
end
