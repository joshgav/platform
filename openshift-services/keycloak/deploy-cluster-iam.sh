#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

export openshift_ingress_domain=$(oc get ingresses.config.openshift.io cluster -ojson | jq -r .spec.domain)
export cluster_iam_namespace=cluster-iam
export cluster_keycloak_name=cluster
export cluster_keycloak_realm_name=default
export cluster_keycloak_client_name=openshift
export cluster_keycloak_client_secret_name=keycloak-client-secret-${cluster_keycloak_client_name}
export cluster_identity_provider_name=Keycloak

# note: Keycloak operator only watches its own namespace
echo "INFO: install operator subscription for Keycloak in namespace ${cluster_iam_namespace}"
ensure_namespace ${cluster_iam_namespace} true
export keycloak_namespace=${cluster_iam_namespace}
apply_kustomize_dir ${this_dir}/operator
await_resource_ready "keycloak"

echo "INFO: install ${cluster_keycloak_name} Keycloak instance in namespace ${cluster_iam_namespace}"
apply_kustomize_dir ${this_dir}/cluster

echo "INFO: wait for ${cluster_keycloak_name} Keycloak instance to be ready"
keycloak_status="false"
while [[ "${keycloak_status}" != "true" ]]; do
    keycloak_status=$(oc get keycloaks.keycloak.org ${cluster_keycloak_name} -n ${cluster_iam_namespace} -o json | \
                        jq -r '.status.ready')
    if [[ ${keycloak_status} != 'true' ]]; then
        echo "INFO: awaiting keycloak instance readiness"
        sleep 2
    else
        echo "INFO: keycloak ready"
    fi
done

echo "INFO: wait for ${cluster_keycloak_realm_name} Keycloak realm to be ready"
realm_status="false"
while [[ "${realm_status}" != "true" ]]; do
    realm_status=$(oc get keycloakrealms.keycloak.org ${cluster_keycloak_realm_name} -n ${cluster_iam_namespace} -o json | \
                        jq -r '.status.ready')
    if [[ ${realm_status} != 'true' ]]; then
        echo "INFO: awaiting keycloak realm readiness"
        sleep 2
    else
        echo "INFO: keycloak realm ready"
    fi
done

echo "INFO: wait for ${cluster_keycloak_client_name} Keycloak client to be ready"
client_status="false"
while [[ "${client_status}" != "true" ]]; do
    client_status=$(oc get keycloakclients.keycloak.org ${cluster_keycloak_client_name} -n ${cluster_iam_namespace} -o json | \
                        jq -r '.status.ready')
    if [[ ${client_status} != 'true' ]]; then
        echo "INFO: awaiting keycloak client readiness"
        sleep 2
    else
        echo "INFO: keycloak client ready"
    fi
done

## copy ${cluster_keycloak_client_secret_name} client secret to openshift-config namespace
## "clientSecret" key name is required, see https://github.com/openshift/api/blob/master/config/v1/types_oauth.go#L506
echo "INFO: copy ${cluster_keycloak_client_secret_name} keycloak client secret to openshift-config namespace"
## TODO: wait for secret to be ready
cluster_keycloak_client_secret_value=$(oc get secret -n ${cluster_iam_namespace} ${cluster_keycloak_client_secret_name} -ojson | jq -r '.data.CLIENT_SECRET | @base64d')
oc apply -n openshift-config -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${cluster_keycloak_client_secret_name}
stringData:
  clientSecret: ${cluster_keycloak_client_secret_value}
EOF

# add ${cluster_identity_provider_name} IdentityProvider to oauth.config.openshift.io/cluster
# pointing to Keycloak realm ${cluster_keycloak_realm_name}
existing_idp=$(oc get oauths.config.openshift.io cluster -ojson | jq ".spec.identityProviders[] | select (.name == \"${cluster_identity_provider_name}\")")
if [[ -z "${existing_idp}" ]]; then
    echo "INFO: adding Keycloak as IDP for OpenShift as ${cluster_identity_provider_name}"
    oc patch oauths cluster --type json --patch "$(cat ${this_dir}/cluster/patch.yaml.tpl | envsubst)"
else
    echo "INFO: Keycloak already added as IDP for OpenShift"
fi
