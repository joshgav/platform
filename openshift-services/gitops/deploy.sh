#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

kustomize build ${this_dir}/operator | oc apply -f -

ready=false
while ! ${ready}; do
    oc api-resources | grep argo &> /dev/null
    if [[ $? == 0 ]]; then
        echo "INFO: operator is ready"
        ready=true
    else
        echo "INFO: awaiting readiness of operator..."
        sleep 1
    fi
done

kustomize build ${this_dir}/base | oc apply -f -
