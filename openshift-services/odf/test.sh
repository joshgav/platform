#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

bucket_name=${1:-"my-bucket"}

oc apply -f - <<EOF
apiVersion: objectbucket.io/v1alpha1
kind: ObjectBucketClaim
metadata:
  name: ${bucket_name}-claim
  namespace: openshift-storage
spec:
  generateBucketName: ${bucket_name}
  storageClassName: openshift-storage.noobaa.io
  additionalConfig:
    bucketClass: noobaa-default-bucket-class
EOF

oc project openshift-storage

phase=''
while [[ "${phase}" != "Bound" ]]; do
    phase=$(oc get obc ${bucket_name}-claim -o json | jq -r '.status.phase')
    sleep 1
done


export AWS_ACCESS_KEY_ID=$(oc get secret ${bucket_name}-claim -o json | jq -r '.data.AWS_ACCESS_KEY_ID | @base64d')
export AWS_SECRET_ACCESS_KEY=$(oc get secret ${bucket_name}-claim -o json | jq -r '.data.AWS_SECRET_ACCESS_KEY | @base64d')
export BUCKET_HOST=$(oc get configmap ${bucket_name}-claim -o json | jq -r '.data.BUCKET_HOST')
s3_hostname=$(oc get route s3 -n openshift-storage -o json | jq -r '.status.ingress[0].host')
export BUCKET_HOST_EXTERNAL="https://${s3_hostname}/"
export BUCKET_NAME=$(oc get configmap ${bucket_name}-claim -o json | jq -r '.data.BUCKET_NAME')
export BUCKET_PORT=$(oc get configmap ${bucket_name}-claim -o json | jq -r '.data.BUCKET_PORT')

echo "INFO: copying files from ${this_dir} into bucket ${BUCKET_NAME}"
aws s3 cp --no-verify-ssl --recursive ${this_dir} s3://${BUCKET_NAME}/ \
    --endpoint-url="${BUCKET_HOST_EXTERNAL}"

echo "INFO: listing files"
aws s3 ls --no-verify-ssl ${BUCKET_NAME} \
    --endpoint-url="${BUCKET_HOST_EXTERNAL}"
