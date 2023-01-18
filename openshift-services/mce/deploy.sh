#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

operator_name=multicluster-engine
operator_namespace=multicluster-engine

echo "INFO: install mce operator"
create_subscription ${operator_name} ${operator_namespace}
await_resource_ready 'multiclusterengine'

echo "INFO: install mce"
oc apply -f - <<EOF
apiVersion: multicluster.openshift.io/v1
kind: MultiClusterEngine
metadata:
  name: multiclusterengine
spec: {}
EOF
kubectl wait mce/multiclusterengine --for condition=Available --timeout=1200s

oc patch MultiClusterEngine multiclusterengine --type=json \
    -p='[{"op": "add", "path": "/spec/overrides/components/-","value":{"name":"hypershift-preview","enabled":true}}]'

echo "INFO: install cluster image sets"
cluster_image_sets_version=release-2.6
channel=fast

_tempdir=$(mktemp -d)
pushd "${_tempdir}"
git clone https://github.com/stolostron/acm-hive-openshift-releases.git
cd acm-hive-openshift-releases
git checkout origin/${cluster_image_sets_version}

find ./clusterImageSets/fast \
    -type d -exec oc apply -f {} \;
popd

echo "INFO: install infrastructure management service"
kustomize build ${this_dir}/assisted | oc apply -f -
kubectl wait agentserviceconfig/agent --for condition=DeploymentsHealthy --timeout=300s
