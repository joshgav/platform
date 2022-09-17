#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

namespace=quarkus-superheroes
ensure_namespace ${namespace} true

repo_dir=${this_dir}/superheroes

for service in "villains" "heroes"; do
    echo "INFO: destroying service ${service}"
    kustomize build ${this_dir}/rest-${service} | kubectl delete -f -

    db_name=${service}-db
    service_name=rest-${service}

    kubectl delete postgrescluster "${db_name}"
    kubectl delete services.serving.knative.dev "${service_name}"
    kubectl delete servicebindings "${service_name}-${db_name}"
done
