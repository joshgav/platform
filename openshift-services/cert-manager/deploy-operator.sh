#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

## Subscription via OLM
# TODO: operator subscription causes problems with cluster-admin ClusterRole

# echo "INFO: install operator subscription"
# kustomize build ${this_dir}/operator | oc apply -f -

# ready=1
# while [[ ${ready} != 0 ]]; do
#     echo "INFO: awaiting readiness of operator"
#     kubectl api-resources | grep cert-manager &> /dev/null
#     ready=$?
# done

# echo "INFO: awaiting readiness of operator"
# kubectl wait --timeout=90s --for=condition=Available deployment.apps cert-manager \
#     --namespace openshift-cert-manager

# echo "INFO: configure certManager"
# kubectl apply -f ${this_dir}/operator/certmanager.yaml

## Use cmctl

source ${root_dir}/lib/requirements.sh
install_cmctl

## We modify the nameservers used for DNS01 ACME checks to ensure they work on AWS.
if ! cmctl check api &> /dev/null; then
    echo "INFO: cert-manager not discovered, attempting to install"
    cmctl experimental install \
        --namespace cert-manager \
        --set extraArgs={'--dns01-recursive-nameservers=8.8.8.8:53,8.8.4.4:53'}
else
    echo "INFO: cert-manager already installed"
fi

ready=1
while [[ ${ready} != 0 ]]; do
    echo "INFO: awaiting readiness of operator"
    kubectl api-resources | grep cert-manager &> /dev/null
    ready=$?
done
