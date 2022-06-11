#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

namespace=freeipa

kubectl get deployment -n ${namespace} idm-operator-controller-manager &> /dev/null
if [[ $? == 1 ]]; then
    export WANT_INSTALL=1
fi

if [[ (-z "${SKIP_OPERATOR_INSTALL}") && (-n "${WANT_INSTALL}") ]]; then
    echo "INFO: installing freeipa-operator via \`make deploy-cluster\`"
    pushd $(mktemp -d)
        git clone https://github.com/freeipa/freeipa-operator.git .

        mkdir -p ./bin
        cp $(which kustomize) ./bin
        cp $(which controller-gen) ./bin

        export WATCH_NAMESPACE=${namespace}
        make undeploy-cluster
        make deploy-cluster IMG=quay.io/freeipa/freeipa-operator:nightly
    popd
fi

# kubectl create secret generic idm-password \
#     --from-literal=IPA_ADMIN_PASSWORD="${IPA_ADMIN_PASSWORD}" \
#     --from-literal=IPA_DM_PASSWORD="${IPA_DM_PASSWORD}"

config_path=${root_dir}/config/freeipa

echo "INFO: prerender manifests"
for file in $(dir ${config_path}/base/*.yaml.tpl); do 
    echo "rendering ${file} to ${file%%'.tpl'}"
    cat "${file}" | envsubst > "${file%%'.tpl'}"
done

kustomize build ${config_path} | kubectl apply -f -
