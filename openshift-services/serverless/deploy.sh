#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
# source ${root_dir}/lib/olm-subscriptions.sh

# echo "INFO: install knative operator via OLM"
# if is_openshift; then
#     operator_name=serverless-operator
#     namespace=openshift-serverless
# else
#     operator_name=knative-operator
#     namespace=knative-operator
# fi

kustomize build ${this_dir}/base | kubectl apply -f -
