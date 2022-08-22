function render_yaml {
    local directory=${1:-'.'}

    echo "INFO: rendering env vars in manifests"
    for file in $(find ${directory} -type f -iname '*.tpl'); do 
        echo "DEBUG: rendering ${file} to ${file%%'.tpl'}"
        cat "${file}" | envsubst > "${file%%'.tpl'}"
    done
}

function apply_kustomize_dir {
    local directory=${1:-'.'}

    echo "INFO: rendering and applying kustomize dir ${directory}"
    if [[ -e "${directory}/.env" ]]; then
        echo "INFO: sourcing .env found in kustomize dir"
        set -o allexport
        source ${directory}/.env
        set +o allexport
    fi
    render_yaml "${directory}"
    kustomize build ${directory} | kubectl apply -f -
}