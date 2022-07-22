#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
repo_dir=${this_dir}/superheroes

namespace=superheroes
kubectl config set-context --current --namespace ${namespace}

for service in "villains" "heroes"; do
    echo "INFO: deploying service ${service}"
    kustomize build ${this_dir}/rest-${service} | kubectl delete -f -

    db_name=${service}-db
    service_name=rest-${service}

    kubectl delete postgrescluster "${db_name}"
    kubectl delete services.serving.knative.dev "${service_name}"
    kubectl delete servicebindings "${service_name}-${db_name}"
done
