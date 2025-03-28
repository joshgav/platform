#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

export quay_server_name=quay.aws.joshgav.com
export quay_certificate_name=quay-aws-joshgav-com
export quay_certificate_secret_name=quay-aws-joshgav-com-keypair
ensure_namespace quay "true"

render_yaml ${this_dir}/registry
oc apply -f ${this_dir}/registry/certificate.yaml
oc wait --for=condition=Ready='true' certificates ${quay_certificate_name}

# get key and cert, keep them in base64 to easily transfer to config secret
export quay_tls_key_b64=$(oc get secret ${quay_certificate_secret_name} -ojson | jq -r '.data["tls.key"]')
export quay_tls_crt_b64=$(oc get secret ${quay_certificate_secret_name} -ojson | jq -r '.data["tls.crt"]')

apply_kustomize_dir ${this_dir}/operator
await_resource_ready quayregistries

apply_kustomize_dir ${this_dir}/registry
