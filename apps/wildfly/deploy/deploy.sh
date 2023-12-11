#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

namespace=test1
ensure_namespace ${namespace} true
ensure_helm_repo wildfly https://docs.wildfly.org/wildfly-charts/

helm upgrade --install helloworld wildfly/wildfly --values - <<EOF
    build:
        uri: https://github.com/joshgav/platform.git
        ref: wildfly
        contextDir: apps/wildfly
        mode: bootable-jar
        env:
        - name: MAVEN_ARGS_APPEND
          value: -Pbootable-jar-openshift
    deploy:
        replicas: 1
EOF

# oc apply -f ${this_dir}/resources/wildflyserver.yaml
