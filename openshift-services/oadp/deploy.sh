#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh
source ${root_dir}/lib/ensure_bucket.sh

export oadp_namespace=openshift-adp
ensure_namespace ${oadp_namespace} true

kustomize build ${this_dir}/operator | oc apply -f -
await_resource_ready dataprotectionapplications

export oadp_bucketname=${oadp_namespace}

oc get secret -n ${oadp_namespace} ${oadp_bucketname}-s3-creds > /dev/null
if [[ $? != 0 ]]; then
  ensure_bucket ${oadp_bucketname} ${oadp_namespace}
  oc create secret generic -n ${oadp_namespace} ${oadp_bucketname}-s3-creds \
    --from-literal=credential="$(echo -e "[default]\naws_access_key_id=${S3_ACCESS_KEY_ID}\naws_secret_access_key=${S3_SECRET_ACCESS_KEY}\n" | envsubst)"
fi

kustomize build ${this_dir}/operand | oc apply -f -

# kubectl apply -f ${this_dir}/examples/backup.yaml
