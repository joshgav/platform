#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi

## for use with QuayRegistry
## see https://docs.redhat.com/en/documentation/red_hat_quay/3.12/html/deploying_the_red_hat_quay_operator_on_openshift_container_platform/operator-preconfigure#operator-managed-storage

oc apply -f ${this_dir}/noobaa/noobaa.yaml
oc apply -f ${this_dir}/noobaa/backingstore.yaml

oc patch bucketclass noobaa-default-bucket-class --patch '{"spec":{"placementPolicy":{"tiers":[{"backingStores":["noobaa-pv-backing-store"]}]}}}' --type merge -n openshift-storage