#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

kubectl apply -f https://github.com/instana/instana-agent-operator/releases/latest/download/instana-agent-operator-no-conversion-webhook.yaml

echo "INFO: prerender manifests"
for file in $(dir ${this_dir}/base/*.yaml.tpl); do 
    echo "rendering ${file} to ${file%%'.tpl'}"
    cat "${file}" | envsubst > "${file%%'.tpl'}"
done

echo "INFO: render and apply manifests"
kustomize build ${this_dir}/base | kubectl apply -f -
