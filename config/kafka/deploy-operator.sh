#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

namespace=kafka
operator_deployment_name=strimzi-cluster-operator

kubectl create namespace ${namespace} &> /dev/null || true

kubectl get deployment -n ${namespace} ${operator_deployment_name} &> /dev/null
if [[ $? == 1 ]]; then
    echo "INFO: kafka operator not found, installing now"
    kubectl create \
        -n ${namespace} \
        -f 'https://strimzi.io/install/latest?namespace=${namespace}'
else
    echo "INFO: kafka operator already installed"
fi

kubectl wait deployment/${operator_deployment_name} --for=condition=Available \
    --timeout=300s -n ${namespace}
