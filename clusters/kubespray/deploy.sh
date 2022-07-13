#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

servers=("server01" "server02" "server03")
kubespray_version=v2.19.0
d=podman

for instance in "${servers[@]}"; do
    ${root_dir}/clouds/aws/deploy-instance.sh ${instance}
done

declare -a ips=()
for instance in "${servers[@]}"; do
    ips+=($(aws cloudformation describe-stacks --stack-name ${instance} --output json | \
        jq -r '.Stacks[0].Outputs[0].OutputValue'))
done

echo "IPs: ${ips[@]}"

## ------

${d} pull quay.io/kubespray/kubespray:${kubespray_version}

${d} run --rm -it \
  --mount type=bind,source=${this_dir}/inventory/cluster,dst=/inventory,relabel=shared \
  --mount type=bind,source=${root_dir}/.ssh/id_rsa,dst=/root/.ssh/id_rsa,relabel=shared \
  --env CONFIG_FILE=/inventory/hosts.yaml \
      quay.io/kubespray/kubespray:${kubespray_version} \
          python3 /kubespray/contrib/inventory_builder/inventory.py "${ips[@]}"

# ${d} run --rm -it \
#   --mount type=bind,source=${this_dir}/inventory/cluster,dst=/inventory \
#   --mount type=bind,source=${root_dir}/.ssh/id_rsa,dst=/root/.ssh/id_rsa \
#       quay.io/kubespray/kubespray:${kubespray_version} -- \
#         ansible-playbook cluster.yml \
#             -i /inventory/hosts.yaml --private-key /root/.ssh/id_rsa \
#             --become --become-user=root
