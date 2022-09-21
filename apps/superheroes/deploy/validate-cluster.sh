#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
app_dir=$(cd ${this_dir}/.. && pwd)
root_dir=$(cd ${this_dir}/../../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

echo "INFO: ensuring resource definitions exist for required services"

ensure_resource_exists postgres-operator.crunchydata.com/v1beta1
ensure_resource_exists registry.apicur.io/v1
ensure_resource_exists kafka.strimzi.io/v1beta2
ensure_resource_exists mongodbcommunity.mongodb.com/v1
ensure_resource_exists serving.knative.dev/v1
ensure_resource_exists opentelemetry.io/v1alpha1
