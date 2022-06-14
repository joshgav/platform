#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

source ${root_dir}/lib/requirements.sh

install_cmctl

## Prefer Helm chart via cmctl CLI over subscription to operator, because Helm chart/cmctl can be modified.
## We modify the nameservers used for DNS01 ACME checks to ensure they work on AWS.
if ! cmctl check api &> /dev/null; then
    echo "INFO: cert-manager not discovered, attempting to install"
    cmctl experimental install --namespace cert-manager
else
    echo "INFO: cert-manager already installed"
fi

# echo "INFO: prerender manifests"
# for file in $(dir ${config_path}/base/*.yaml.tpl); do 
#     echo "rendering ${file} to ${file%%'.tpl'}"
#     cat "${file}" | envsubst > "${file%%'.tpl'}"
# done

echo "INFO: render and apply manifests"
kustomize build ${this_dir}/libvirt | oc apply -f -
