#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

echo "INFO: installing required operators"
apply_kustomize_dir ${this_dir}/operators
await_resource_ready "clusterlogforwarders"
await_resource_ready "lokistacks"

oc config set-context --current --namespace openshift-logging

# for legacy stack use this instead:
# apply_kustomize_dir ${this_dir}/legacy

export S3_BUCKET_NAME=${S3_BUCKET_NAME:-loki-data}
apply_kustomize_dir ${this_dir}/loki-prep

bucket_phase='Pending'
while [[ "${bucket_phase}" != "Bound" ]]; do
    echo "INFO: awaiting binding of bucket claim ${S3_BUCKET_NAME}-claim"
    bucket_phase=$(oc get objectbucketclaim ${S3_BUCKET_NAME}-claim -ojson | jq -r '.status.phase')
done
echo "INFO: bucket claim ${S3_BUCKET_NAME}-claim bound"

# export S3_ENDPOINT_URL=$(oc get -n noobaa noobaas noobaa -ojson | jq -r '.status.services["serviceS3"].externalDNS[0]')
export S3_ENDPOINT_URL=$(oc get -n noobaa noobaas noobaa -ojson | jq -r '.status.services["serviceS3"].internalDNS[0]')
export S3_ACCESS_KEY_ID=$(oc get secret ${S3_BUCKET_NAME}-claim -ojson | jq -r '.data.AWS_ACCESS_KEY_ID | @base64d')
export S3_SECRET_ACCESS_KEY=$(oc get secret ${S3_BUCKET_NAME}-claim -ojson | jq -r '.data.AWS_SECRET_ACCESS_KEY | @base64d')

apply_kustomize_dir ${this_dir}/loki

oc wait --for=condition=Ready lokistacks logging-loki

apply_kustomize_dir ${this_dir}/logging
