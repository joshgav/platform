#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh
source ${root_dir}/lib/ensure_bucket.sh

## OpenShift Service Mesh instructions:
## - https://docs.redhat.com/en/documentation/red_hat_openshift_service_mesh/3.0/html/installing/ossm-installing-service-mesh#ossm-about-bookinfo-application_ossm-discoveryselectors-scope-service-mesh

kustomize build ${this_dir}/tempo-operator | oc apply -f -
await_resource_ready tempostack
kustomize build ${this_dir}/coo | oc apply -f -
await_resource_ready uiplugin

export tempo_namespace='tempo-observability'
export tempo_bucketname=${tempo_namespace}
ensure_namespace ${tempo_namespace} true

oc get secret -n ${tempo_namespace} ${tempo_bucketname}-secret > /dev/null
if [[ $? != 0 ]]; then
  ensure_bucket ${tempo_bucketname} ${tempo_namespace}
  ## FIX: with `:443` at the end Tempo uses HTTP
  export S3_ENDPOINT_URL=https://s3.openshift-storage.svc
  oc create secret generic -n ${tempo_namespace} ${tempo_bucketname}-secret \
    --from-literal=endpoint=${S3_ENDPOINT_URL} \
    --from-literal=bucket=${S3_BUCKET_NAME} \
    --from-literal=access_key_id=${S3_ACCESS_KEY_ID} \
    --from-literal=access_key_secret=${S3_SECRET_ACCESS_KEY}
fi

kustomize build ${this_dir}/tempo-configuration | oc apply -f -
