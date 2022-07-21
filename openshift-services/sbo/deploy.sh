#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

echo "INFO: install operator subscription"
oc apply -f ${this_dir}/subscription.yaml

ready=1
while [[ ${ready} != 0 ]]; do
    echo "INFO: awaiting readiness of operator"
    kubectl api-resources | grep servicebinding &> /dev/null
    ready=$?
done
