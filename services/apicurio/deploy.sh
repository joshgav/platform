#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

source ${root_dir}/lib/kubernetes.sh

operator_name=apicurio-registry
echo "INFO: install ${operator_name} via OLM"
create_subscription ${operator_name}

await_resource_ready apicurioregistries

namespace=apicurio
ensure_namespace ${namespace} true

echo "INFO: installing an Apicurio registry"
echo "INFO: installing postgres for Apicurio"
kubectl apply -n ${namespace} -f ${this_dir}/registry/postgrescluster.yaml

ready=0
while [[ "${ready}" == "0" ]]; do
    echo "INFO: checking if DB is ready"
    ready=$(kubectl get postgresclusters apicurio-dbcluster --output json | jq -r '.status.instances[0].readyReplicas')
    if [[ "${ready}" == "0" ]]; then
        echo "INFO: awaiting DB readiness"
        sleep 2
    fi
done

echo "INFO: installing Apicurio"
db_bindings=$(kubectl get secret apicurio-dbcluster-pguser-apicurio --output json | jq -r '.data')
export DB_URL=$(echo "${db_bindings}" | jq -r '."jdbc-uri" | @base64d' | sed 's/\?.*$//')
export DB_USERNAME=$(echo "${db_bindings}" | jq -r '.user | @base64d')
export DB_PASSWORD=$(echo "${db_bindings}" | jq -r '.password | @base64d')
cat ${this_dir}/registry/registry.yaml.tpl | envsubst > ${this_dir}/registry/registry.yaml
kubectl apply -f ${this_dir}/registry/registry.yaml

kubectl wait --for condition=Ready apicurioregistries/apicurio-registry

route_host=$(kubectl get routes -l "app=apicurio-registry" --output json | jq -r '.items[0].status.ingress[0].host')
echo "INFO: registry is available at http://${route_host}/"
