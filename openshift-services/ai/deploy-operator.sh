#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh
source ${root_dir}/lib/aws.sh

namespace=redhat-ods-operator
ensure_namespace ${namespace} true
create_cluster_operatorgroup ${namespace}
create_subscription rhods-operator
