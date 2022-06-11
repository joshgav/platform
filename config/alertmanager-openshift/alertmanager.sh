#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

# see https://prometheus.io/docs/alerting/latest/configuration/

# temp_file=$(mktemp)
# oc get secret --namespace openshift-monitoring alertmanager-main -o json | \
#     jq -r '.data."alertmanager.yaml"' | base64 --decode > ${temp_file}

alertmanager_config=$(cat "${this_dir}/alertmanager.yaml.tpl" | envsubst)
oc create secret generic alertmanager-main --from-literal=alertmanager.yaml="${alertmanager_config}" --dry-run=client --output=yaml |
    oc replace secret -n openshift-monitoring --filename=-
