function setup_workdir {
    local workdir=${1:-"${this_dir:-'.'}/_workdir"}

    if [[ -e ${workdir} && -z "${RESUME}" && -z "${OVERWRITE}" ]]; then
        echo "WARNING: workdir already exists, set OVERWRITE=1 to remove or RESUME=1 to continue"
        exit 2
    elif [[ -e ${workdir} && -n "${RESUME}" ]]; then
        echo "INFO: continuing from existing workdir"
    elif [[ -e ${workdir} && -n "${OVERWRITE}" ]]; then
        rm -rf ${workdir}
        mkdir -p "${workdir}"
    else
        mkdir -p "${workdir}"
    fi
}

function ensure_ssh_keypair {
    keypair_path=${1:-"${root_dir:-'.'}/.ssh"}

    mkdir -p "${ssh_key_path}"
    if [[ ! -e "${ssh_key_path}/id_rsa" ]]; then
        ssh-keygen -t rsa -b 4096 -C "user@openshift" -f "${ssh_key_path}/id_rsa" -N ''
    fi
}
