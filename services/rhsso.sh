#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

source ${root_dir}/lib/operators.sh

namespace=app
oc create namespace ${namespace} 2> /dev/null || true
create_local_operatorgroup ${namespace}

echo
echo "INFO: install rhsso-operator"
create_subscription rhsso-operator ${namespace}

cat ${root_dir}/config/keycloak/base/realm.yaml.tpl | \
  envsubst '${LDAP_BIND_SECRET}' > ${root_dir}/config/keycloak/base/realm.yaml

kustomize build ${root_dir}/config/keycloak | oc apply -f -
