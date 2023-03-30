#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -e ${this_dir}/.env ]]; then source ${this_dir}/.env; fi
source ${this_dir}/lib/aws.sh

## destroy infrastructure
echo "INFO: destroy infrastructure"
stages=(
    "06_cluster_worker_node"
    "05_cluster_master_nodes"
    "04_cluster_bootstrap"
    "03_cluster_security"
    "02_cluster_infra"
    "01_vpc"
)

for stage in "${stages[@]}"; do
    echo "INFO: destroy cfn stack \"${stage}\""
    destroy_stack ${stage}
done

## TODO: delete S3 bucket with ignition config
