#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
workdir=${this_dir}/_workdir
export KUBECONFIG=${workdir}/auth/kubeconfig

while true; do
    csrs=($(oc get csr -o json | jq -r '.items[] | select(.status == {}) | .metadata.name'))
    for csr in "${csrs[@]}"; do
        oc adm certificate approve "${csr}"
    done
    sleep 5
done
