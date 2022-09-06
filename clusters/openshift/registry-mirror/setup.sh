#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/../../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

registry_hostname=registry-quay-quay.apps.${OPENSHIFT_CLUSTER_NAME}.${OPENSHIFT_BASE_DOMAIN}

# Note that we don't log into quay.io or registry.redhat.io explicitly;
# Instead we copy the special pull secret. This is required.
echo "${OPENSHIFT_PULL_SECRET}" > /run/user/${UID}/containers/auth.json

# login to cluster-local Quay instance
podman login ${registry_hostname} \
    --username ${QUAY_REGISTRY_USERNAME} --password ${QUAY_REGISTRY_PASSWORD}

if [[ ! -f ${this_dir}/imageset-config.yaml ]]; then
    oc mirror init \
        --registry=${registry_hostname}/openshift-mirror/data \
            > ${this_dir}/imageset-config.yaml
fi

oc mirror --config=${this_dir}/imageset-config.yaml docker://${registry_hostname}/openshift-mirror/data
