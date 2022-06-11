#! /usr/bin/env -S bash -e

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

# TODO: ensure virtual machine is consistent with parameters
echo "registering local persistent volume and storageclass"
kubectl apply -f ${this_dir}/pv.yaml
