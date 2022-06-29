#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

echo "INFO: install operator subscription"
kustomize build ${this_dir}/operator | oc apply -f -

ready=1
while [[ ${ready} != 0 ]]; do
    echo "INFO: awaiting readiness of operator"
    kubectl api-resources | grep keycloak &> /dev/null
    ready=$?
done
