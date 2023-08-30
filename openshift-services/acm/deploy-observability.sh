#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

namespace=open-cluster-management-observability
bucket_name=acm-observability

ensure_namespace ${namespace} true

# DOCKER_CONFIG_JSON=$(oc extract secret/multiclusterhub-operator-pull-secret -n open-cluster-management --to=-)
DOCKER_CONFIG_JSON=$(oc extract secret/pull-secret -n openshift-config --to=-)
oc create secret generic multiclusterhub-operator-pull-secret \
    -n open-cluster-management-observability \
    --from-literal=.dockerconfigjson="${DOCKER_CONFIG_JSON}" \
    --type=kubernetes.io/dockerconfigjson

ensure_bucket ${bucket_name} ${namespace} true

S3_ENDPOINT_URL=$(echo "${S3_ENDPOINT_URL}" | sed 's/^https*:\/\///' | sed 's/:.*$//')
echo "INFO: using S3_ENDPOINT_URL: ${S3_ENDPOINT_URL}"

apply_kustomize_dir ${this_dir}/observability
