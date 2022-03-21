#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

tempdir=$(mktemp -d)
export PATH=${tempdir}:${PATH}

### openshift-install (https://github.com/openshift/installer)

if ! type -p openshift-install &> /dev/null; then
    installer_url=https://mirror.openshift.com/pub/openshift-v4/clients/ocp/fast/openshift-install-linux.tar.gz
    filename=openshift-install-linux.tar.gz

    echo
    echo "INFO: downloading openshift-install"

    pushd ${tempdir}
        curl -o "${filename}" -sSL "${installer_url}"
        tar -xzf "${filename}"
        rm "${filename}"
    popd
else
    echo
    echo "INFO: using installed openshift-install"
fi

### AWS CLI

if ! type -p aws &> /dev/null; then
    installer_url=https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
    filename=awscliv2.zip

    echo
    echo "INFO: downloading and installing aws CLI"

    pushd ${tempdir}
        curl -o "${filename}" -sSL "${installer_url}"
        unzip -d aws-src "${filename}" 1> /dev/null
        ./aws-src/aws/install --install-dir ${tempdir}/usr/local/aws-cli --bin-dir ${tempdir}
        rm "${filename}"
    popd
else
    echo
    echo "INFO: using installed aws CLI"
fi
