#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

namespace=app
kubectl create namespace ${namespace} 2> /dev/null || true
kubectl config set-context --current --namespace=${namespace}

if is_openshift; then
    dir_name=base-openshift
else
    dir_name=base-k8s
fi

kustomize build ${this_dir}/${dir_name} | kubectl apply -n ${namespace} -f -

if [[ -n "${ENABLE_KEYCLOAK}" ]]; then
    # export openshift_ingress_domain=$(oc get ingresses.config.openshift.io cluster -ojson | jq -r .spec.domain)
    kubectl apply -n keycloak -f ${this_dir}/keycloak/spring-apiserver-client.yaml

    CLIENT_SECRET=$(kubectl get secret -n keycloak keycloak-client-secret-spring-apiserver -o json | jq -r '.data.CLIENT_SECRET | @base64d')
    kubectl create secret generic -n app keycloak-client-secret-spring-apiserver \
        --from-literal=CLIENT_ID=spring-apiserver \
        --from-literal=CLIENT_SECRET=${CLIENT_SECRET}
    kubectl patch --type strategic --filename=${this_dir}/${dir_name}/deployment.yaml --patch-file=${this_dir}/keycloak/deployment.yaml
fi
