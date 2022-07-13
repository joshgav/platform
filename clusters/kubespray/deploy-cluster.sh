#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

d=podman
v=v2.19.0

${d} pull quay.io/kubespray/kubespray:${v}

${d} run --rm -it \
    --mount type=bind,source=${this_dir}/inventory/cluster,dst=/inventory,relabel=shared \
    --mount type=bind,source=${root_dir}/.ssh/id_rsa,dst=/root/.ssh/id_rsa,relabel=shared \
        quay.io/kubespray/kubespray:${v} \
            ansible-playbook cluster.yml \
                -i /inventory/hosts.ini \
                --private-key /root/.ssh/id_rsa \
                --become --become-user=root
