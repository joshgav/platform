#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

namespace=cert-manager
secret_name=ca-root-keypair
local_trust_root=/etc/pki/ca-trust/source/anchors

kubectl get secrets -n ${namespace} ${secret_name} -o json | \
    jq -r '.data."ca.crt" | @base64d' \
        > ${this_dir}/ca-root.pem

cp ${this_dir}/ca-root.pem ${local_trust_root}/
update-ca-trust
