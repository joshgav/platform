#! /usr/bin/env -S bash -e

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

export device_name=${1:-${device_name:-"vdb"}}

# TODO: ensure virtual machine is consistent with parameters
echo "INFO: registering local persistent block volume and storageclass for /dev/${device_name}"
cat ${this_dir}/pv.yaml.tpl | envsubst | kubectl apply -f -
