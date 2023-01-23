#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi

# must manually add redirect URIs to OAuth client in portal
# have not found a way to automate this :(
# https://console.cloud.google.com/apis
# redirect URI: https://oauth-openshift.apps.${CLUSTER_NAME}.${BASE_DOMAIN}/oauth2callback/Google
# redirect URI: https://oauth-openshift.apps.${CLUSTER_NAME}.${BASE_DOMAIN}/oauth2callback/Gmail

oc delete secret google-signin -n openshift-config &> /dev/null
oc create secret generic google-signin -n openshift-config \
    --from-literal="clientSecret=${GOOGLE_SIGNIN_CLIENT_SECRET}"

oc patch oauths.config.openshift.io cluster --type merge --patch "
spec:
  identityProviders:
    - name: Google
      mappingMethod: claim
      type: Google
      google:
        hostedDomain: redhat.com
        clientID: '${GOOGLE_SIGNIN_CLIENT_ID}'
        clientSecret:
          name: google-signin
    - name: Gmail
      mappingMethod: lookup
      type: Google
      google:
        clientID: '${GOOGLE_SIGNIN_CLIENT_ID}'
        clientSecret:
          name: google-signin
"

if [[ -n "${GOOGLE_IDENTITY_NUMBER}" ]]; then
  oc create identity Gmail:${GOOGLE_IDENTITY_NUMBER}
  oc create user ${GOOGLE_IDENTITY_NAME} --full-name="${GOOGLE_IDENTITY_FULLNAME}"
  oc create useridentitymapping Gmail:${GOOGLE_IDENTITY_NUMBER} ${GOOGLE_IDENTITY_NAME}
  oc adm policy add-cluster-role-to-user cluster-admin ${GOOGLE_IDENTITY_NAME}
fi
