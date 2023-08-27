#! /usr/bin/env bash

pip install --user awxkit
awx --version

CONF_HOST="https://$(oc get route -n ansible-automation-controller ansible-automation-controller -ojson | jq -r '.status.ingress[0].host')"
CONF_PASSWORD=$(oc get secret -n ansible-automation-controller ansible-automation-controller-admin-password -ojson | jq -r '.data.password | @base64d')
CONF_USERNAME=admin

# list all available resource types on server
awx \
    --conf.host ${CONF_HOST} \
    --conf.username ${CONF_USERNAME} \
    --conf.password ${CONF_PASSWORD}

awx me \
    --conf.host ${CONF_HOST} \
    --conf.username ${CONF_USERNAME} \
    --conf.password ${CONF_PASSWORD}

awx ping \
    --conf.host ${CONF_HOST} \
    --conf.username ${CONF_USERNAME} \
    --conf.password ${CONF_PASSWORD}
