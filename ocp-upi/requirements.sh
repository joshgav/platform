#! /usr/bin/env bash

source $(dirname "${BASH_SOURCE[0]}")/vars.sh

function install_openshift_install () {
    install_dir=${1}
    if ! type -P openshift-install &> /dev/null; then
        if [[ -z "${install_dir}" ]]; then
            install_dir=$(mktemp -d)
            export PATH=${install_dir}:${PATH}
        fi
        echo "installing openshift-install to ${install_dir}"

        unzip_dir=$(mktemp -d)
        curl -sSL -o ${unzip_dir}/openshift-install.tar.gz ${ocp_install_url}
        tar -C ${unzip_dir} -xzf ${unzip_dir}/openshift-install.tar.gz
        chmod +x ${unzip_dir}/openshift-install

        mv ${unzip_dir}/openshift-install ${install_dir}/openshift-install

        rm -rf ${unzip_dir}
    fi

    echo "INFO: openshift-install version"
    openshift-install version

    echo "For info see ${ocp_releasetxt_url}"
    echo ""
}

function install_coreos_installer () {
    install_dir=${1}

    if ! type -P coreos-installer &> /dev/null; then
        if [[ -z "${install_dir}" ]]; then
            install_dir=$(mktemp -d)
            export PATH=${install_dir}:${PATH}
        fi
        echo "installing coreos-installer to ${install_dir}"

        curl -sSL -o ${install_dir}/coreos-installer ${coreos_installer_url}
        chmod +x ${install_dir}/coreos-installer
    fi

    echo "INFO: coreos-installer --version"
    coreos-installer --version

}

function download_rhcos_live_iso () {
    dest=${1}
    if [[ -z "${dest}" || ! -d "${dest}" ]]; then
        >&2 echo "must specify valid destination dir"
        return 1
    fi

    temp_dir=${root_dir:-'.'}/temp
    mkdir -p ${temp_dir}
    if [[ ! -f "${temp_dir}/rhcos-live.iso" ]]; then
        echo "caching RHCOS live ISO to ${temp_dir}"
        curl -sSL -o ${temp_dir}/rhcos-live.iso ${rhcos_live_iso_url}
    else
        echo "found cached image, not refreshing"
    fi
    echo "copying cached image to ${dest}"
    cp ${temp_dir}/rhcos-live.iso ${dest}/rhcos-live.iso
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_openshift_install "${@}"
    install_coreos_installer "${@}"
fi