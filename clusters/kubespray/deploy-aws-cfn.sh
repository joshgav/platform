#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

servers=("server01" "server02" "server03")

d=podman
v=v2.19.0

## deploy instances
for instance in "${servers[@]}"; do
    ${root_dir}/clouds/aws/deploy-instance.sh ${instance}
done

# TODO: await readiness of instances

## get instances IP addrs
declare -a ips=()
for instance in "${servers[@]}"; do
    ips+=($(aws cloudformation describe-stacks --stack-name ${instance} --output json | \
        jq -r '.Stacks[0].Outputs[0].OutputValue'))
done
echo "IPs: ${ips[@]}"

## generate inventory file
${d} pull quay.io/kubespray/kubespray:${v}
${d} run --rm -it \
    --mount type=bind,source=${this_dir}/inventory/cluster,dst=/inventory,relabel=shared \
    --mount type=bind,source=${root_dir}/.ssh/id_rsa,dst=/root/.ssh/id_rsa,relabel=shared \
        --env CONFIG_FILE=/inventory/hosts.yaml \
            quay.io/kubespray/kubespray:${v} \
                python3 /kubespray/contrib/inventory_builder/inventory.py ${ips[@]}
