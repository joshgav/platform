#! /usr/bin/env bash

echo "INFO: applying config for Keycloak client"
# export openshift_ingress_domain=$(oc get ingresses.config.openshift.io cluster -ojson | jq -r .spec.domain)
kubectl apply -n keycloak -f ${this_dir}/keycloak/spring-apiserver-client.yaml

CLIENT_SECRET=$(kubectl get secret -n keycloak keycloak-client-secret-spring-apiserver -o json | jq -r '.data.CLIENT_SECRET | @base64d')
kubectl create secret generic -n app keycloak-client-secret-spring-apiserver \
    --from-literal=CLIENT_ID=spring-apiserver \
    --from-literal=CLIENT_SECRET=${CLIENT_SECRET}
kubectl patch --type strategic --filename=${this_dir}/${dir_name}/deployment.yaml --patch-file=${this_dir}/keycloak/deployment.yaml
