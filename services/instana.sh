#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

kubectl apply -f https://github.com/instana/instana-agent-operator/releases/latest/download/instana-agent-operator-no-conversion-webhook.yaml

config_path=${root_dir}/config/instana

echo "INFO: prerender manifests"
for file in $(dir ${config_path}/base/*.yaml.tpl); do 
    echo "rendering ${file} to ${file%%'.tpl'}"
    cat "${file}" | envsubst > "${file%%'.tpl'}"
done

echo "INFO: render and apply manifests"
kustomize build ${config_path} | oc apply -f -
