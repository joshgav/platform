#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

dashboard_ver=v2.6.0
namespace=kubernetes-dashboard

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/${dashboard_ver}/aio/deploy/recommended.yaml
kustomize build ${this_dir}/base | kubectl apply -n ${namespace} -f -

kubectl patch deployment -n ${namespace} kubernetes-dashboard --type strategic \
    --patch-file ${this_dir}/base/patches/dashboard-deployment_patch.yaml

kubectl patch service -n ${namespace} kubernetes-dashboard --type strategic \
    --patch-file ${this_dir}/base/patches/dashboard-service_patch.yaml
