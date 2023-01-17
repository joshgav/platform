#! /usr/bin/env bash

# install types:
# - direct download of binary (e.g. operator-sdk, argocd)
# - download tarball with binary
# - download tarball/zip with install program

# get_install_dir returns the path where the tool should be installed
function get_install_dir {
    install_dir=${1:-${INSTALL_DIR}}

    if [[ -z "${install_dir}" ]]; then
        install_dir=$(mktemp -d)
        echo >&2 "INFO: installing requirements to temp dir ${install_dir} and adding to PATH"
        export PATH="${install_dir}:${PATH}"
    fi

    echo ${install_dir}
}

# install_binary retrieves a binary from download_url and puts it in INSTALL_DIR
# as binary_name
function install_binary {
    local download_url=${1}
    local binary_name=${2}

    install_dir=$(get_install_dir)

    if ! type -p ${binary_name} &> /dev/null; then
        echo "INFO: downloading and installing ${binary_name}"

        pushd ${install_dir}
            curl -o "${binary_name}" -sSL "${download_url}"
            chmod +x ${binary_name}
        popd
    else
        echo "INFO: using installed ${binary_name}"
    fi

    echo "INFO: ${binary_name} version"
    ${binary_name} version
}

function install_from_tarball {
    local download_url=${1}
    local binary_name=${2}

    local file_name="$(basename ${download_url})"

    install_dir=$(get_install_dir)

    if ! type -p ${binary_name} &> /dev/null; then
        echo "INFO: downloading and unpacking ${binary_name}"

        pushd ${install_dir}
            curl -sSL "${download_url}" -o "${file_name}"
            tar -xzf "${file_name}" "${binary_name}"
            rm -f "${file_name}"
        popd
    else
        echo "INFO: using installed ${binary_name}"
    fi
}

function install_rosa_cli {
    download_url=https://mirror.openshift.com/pub/openshift-v4/clients/rosa/latest/rosa-linux.tar.gz
    binary_name=rosa
    install_from_tarball ${download_url} ${binary_name}
    rosa version
}

function install_openshift_install {
    install_dir=$(get_install_dir)
    export PATH="${install_dir}:${PATH}"
    # candidate, fast, latest, stable
    channel=fast
    if ! type -p openshift-install &> /dev/null; then
        installer_url=https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${channel}/openshift-install-linux.tar.gz
        filename=openshift-install-linux.tar.gz

        echo "INFO: downloading openshift-install"

        pushd ${install_dir}
            curl -o "${filename}" -sSL "${installer_url}"
            tar -xzf "${filename}" openshift-install
            rm -f "${filename}"
        popd
    else
        echo "INFO: using installed openshift-install"
    fi
    echo "INFO: openshift-install version"
    openshift-install version
}

function install_aws_cli {
    install_dir=$(get_install_dir)
    export PATH="${install_dir}:${PATH}"
    if ! type -p aws &> /dev/null; then
        installer_url=https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
        filename=awscliv2.zip

        echo "INFO: downloading and installing aws CLI"

        pushd ${install_dir}
            curl -o "${filename}" -sSL "${installer_url}"
            unzip -d aws-src "${filename}" 1> /dev/null
            ./aws-src/aws/install --install-dir ${install_dir}/lib/aws-cli --bin-dir ${install_dir}
            rm "${filename}"
            rm -rf aws-src/
        popd
    else
        echo "INFO: using installed aws CLI"
    fi
    echo "INFO: aws --version"
    aws --version
}

function install_cmctl {
    install_dir=$(get_install_dir)
    export PATH="${install_dir}:${PATH}"
    cmctl_ver=v1.8.0
    if ! type -p cmctl &> /dev/null; then
        installer_url=https://github.com/cert-manager/cert-manager/releases/download/${cmctl_ver}/cmctl-linux-amd64.tar.gz
        filename=cmctl-linux-amd64.tar.gz

        echo "INFO: downloading and installing cmctl"

        pushd ${install_dir}
            curl -o "${filename}" -sSL "${installer_url}"
            tar -xzf "${filename}" ./cmctl
            rm -f "${filename}"
        popd
    else
        echo "INFO: using installed cmctl"
    fi
    echo "INFO: cmctl version --client"
    cmctl version --client
}

function install_security_tools {
    install_dir=$(get_install_dir)
    ## trivy
    echo "installing trivy to ${install_dir}"
    trivy_version=v0.21.1
    curl -sSL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | \
        sh -s -- -b "${install_dir}" "${trivy_version}"
    trivy --version

    ## cosign
    echo ""
    echo "installing cosign to ${install_dir}"
    cosign_version=v1.3.1
    curl -sSL -o "${install_dir}/cosign" https://storage.googleapis.com/cosign-releases/${cosign_version}/cosign-linux-amd64
    chmod +x "${install_dir}/cosign"
    cosign version
}

function install_crossplane_cli {
    install_dir=$(get_install_dir)
    export PATH="${install_dir}:${PATH}"

    kubectl_dir=$(dirname $(which kubectl))

    if [[ ! -e ${kubectl_dir}/kubectl-crossplane ]]; then
        if [[ ${UID} != 0 ]]; then
            echo "WARN: must be root to install kubectl plugin for crossplane"
            return
        else
            curl -sL https://raw.githubusercontent.com/crossplane/crossplane/master/install.sh | sh
            mv kubectl-crossplane ${kubectl_dir}
        fi
    fi
}

function install_tkn_cli {
    install_dir=$(get_install_dir)
    export PATH="${install_dir}:${PATH}"
    tkn_ver=v0.24.0

    if ! type -p tkn &> /dev/null; then
        installer_url=https://github.com/tektoncd/cli/releases/download/${tkn_ver}/tkn_${tkn_ver#v}_Linux_x86_64.tar.gz
        filename=tkn-linux-amd64.tar.gz

        echo "INFO: downloading and installing tkn"

        pushd ${install_dir}
            curl -o "${filename}" -sSL "${installer_url}"
            tar -xzf "${filename}" tkn
            rm -f "${filename}"
        popd
    else
        echo "INFO: using installed tkn"
    fi
    echo "INFO: tkn version"
    tkn version
}

# TODO: use install_binary
function install_argocd_cli {
    install_dir=$(get_install_dir)
    export PATH="${install_dir}:${PATH}"

    if ! type -p argocd &> /dev/null; then
        installer_url=https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
        filename=argocd

        echo "INFO: downloading and installing argocd CLI"

        pushd ${install_dir}
            curl -o "${filename}" -sSL "${installer_url}"
            chmod +x ${filename}
        popd
    else
        echo "INFO: using installed argocd CLI"
    fi

    echo "INFO: argocd version"
    argocd version --client
}

function install_kubebuilder {
    download_url=https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)
    binary_name=kubebuilder
    install_binary ${download_url} ${binary_name}
}

function install_operator_sdk {
    operator_sdk_ver=v1.22.0
    download_url=https://github.com/operator-framework/operator-sdk/releases/download/${operator_sdk_ver}/operator-sdk_linux_amd64
    binary_name=operator-sdk
    install_binary ${download_url} ${binary_name}
}

function install_kn_cli {
    kn_ver=v1.6.1
    download_url=https://github.com/knative/client/releases/download/knative-${kn_ver}/kn-linux-amd64
    binary_name=kn
    install_binary ${download_url} ${binary_name}
}

function install_kn_func_plugin {
    knfunc_ver=v0.25.1
    download_url=https://github.com/knative-sandbox/kn-plugin-func/releases/download/${knfunc_ver}/func_linux_amd64
    binary_name=kn-func
    install_binary ${download_url} ${binary_name}
}

function install_vcluster_cli {
    vcluster_ver=v0.13.0
    download_url=https://github.com/loft-sh/vcluster/releases/download/${vcluster_ver}/vcluster-linux-amd64
    binary_name=vcluster
    install_binary ${download_url} ${binary_name}
}