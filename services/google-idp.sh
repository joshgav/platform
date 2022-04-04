#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

# https://console.cloud.google.com/apis
# redirect URI: https://oauth-openshift.apps.h0lzthzg.eastus.aroapp.io/oauth2callback/Google
# redirect URI: https://oauth-openshift.apps.h0lzthzg.eastus.aroapp.io/oauth2callback/Gmail

oc delete secret google-signin -n openshift-config &> /dev/null
oc create secret generic google-signin -n openshift-config \
    --from-literal="clientSecret=${GOOGLE_SIGNIN_CLIENT_SECRET}"

oc patch oauths.config.openshift.io cluster --type merge --patch "
spec:
  identityProviders:
    - name: redhat.com (Google)
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

# oc create identity Gmail:104049342931051915196
# oc create user joshgavant@gmail.com --full-name="Josh Gavant"
# oc create useridentitymapping Gmail:104049342931051915196 joshgavant@gmail.com
# oc adm policy add-cluster-role-to-user cluster-admin joshgavant@gmail.com