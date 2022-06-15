#! /usr/bin/env bash

function get_install_dir {
    install_dir=${1:-${INSTALL_DIR}}

    if [[ -z "${install_dir}" ]]; then
        install_dir=$(mktemp -d)
        echo >&2 "INFO: installing requirements to temp dir ${install_dir} and adding to PATH"
        export PATH="${install_dir}:${PATH}"
    fi

    echo ${install_dir}
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
    echo "INFO: cmctl version"
    cmctl version
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

function install_operator_sdk {
    install_dir=$(get_install_dir)
    export PATH="${install_dir}:${PATH}"
    export ARCH=amd64
    export OS=linux
    export VER=v1.22.0

    if ! type -p operator-sdk &> /dev/null; then
        installer_url=https://github.com/operator-framework/operator-sdk/releases/download/${VER}/operator-sdk_${OS}_${ARCH}
        filename=operator-sdk

        echo "INFO: downloading and installing operator-sdk CLI"

        pushd ${install_dir}
            curl -o "${filename}" -sSL "${installer_url}"
            chmod +x ${filename}
        popd
    else
        echo "INFO: using installed operator-sdk CLI"
    fi

    echo "INFO: operator-sdk --version"
    operator-sdk version
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