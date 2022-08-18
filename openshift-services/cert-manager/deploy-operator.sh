#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

## Subscription via OLM
echo "INFO: install operator subscription"
kustomize build ${this_dir}/operator | oc apply -f -

ready=1
while [[ ${ready} != 0 ]]; do
    echo "INFO: awaiting readiness of operator"
    kubectl api-resources | grep cert-manager &> /dev/null
    ready=$?
    if [[ ${ready} != 0 ]]; then sleep 2; else echo "INFO: operator ready"; fi
done

# echo "INFO: awaiting readiness of operator"
kubectl wait --timeout=90s --for=condition=Available deployment.apps cert-manager \
    --namespace openshift-cert-manager

echo "INFO: configure default certmanager"
kubectl apply -f ${this_dir}/operator/certmanager.yaml
