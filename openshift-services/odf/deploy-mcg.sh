#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi

${this_dir}/deploy-operator.sh

# ## deploy noobaa manually
# oc apply -f ${this_dir}/mcg/noobaa.yaml
# oc apply -f ${this_dir}/mcg/backingstore.yaml
# oc patch bucketclass noobaa-default-bucket-class --patch '{"spec":{"placementPolicy":{"tiers":[{"backingStores":["noobaa-pv-backing-store"]}]}}}' --type merge -n openshift-storage

kustomize build ${this_dir}/mcg | oc apply -f -
