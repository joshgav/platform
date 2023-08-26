#! /usr/bin/env bash

# Documented here: <https://github.com/noobaa/noobaa-operator/issues/171#issuecomment-847759757>

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

latest_version=$(curl -s https://api.github.com/repos/noobaa/noobaa-operator/releases/latest | jq -r '.name' | sed 's/^v//')

kubectl patch deployment noobaa-operator --patch '{ "spec": { "template": { "spec": { "containers": [{
    "name": "noobaa-operator", 
    "image": "noobaa/noobaa-operator:'${latest_version}'" 
}]}}}}'

kubectl patch noobaa noobaa --type merge --patch '{ "spec": {
  "image": "noobaa/noobaa-core:'${latest_version}'"
}}'
