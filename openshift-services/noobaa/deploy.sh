#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

# uncomment to enable aws-s3 backingstore type
# cat ${this_dir}/system/aws-secret.yaml.tpl | envsubst | kubectl apply -f -

ensure_namespace noobaa true
echo "INFO: installing noobaa in background"
noobaa install &
# install_pid=$!

await_resource_ready noobaa

exists=1
while [[ ${exists} == 1 ]]; do
    echo "INFO: waiting for noobaa resource to be created"
    oc get -n noobaa noobaas.noobaa.io noobaa &> /dev/null
    exists=$?
done

echo "INFO: patching default noobaa resource"
oc patch --type merge --namespace noobaa noobaas.noobaa.io noobaa --patch '{ "spec": {
    "manualDefaultBackingStore": true
}}'

kustomize build ${this_dir}/system | oc apply -f -
wait
