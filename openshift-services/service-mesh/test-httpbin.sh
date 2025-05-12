#! /usr/bin/env bash

curl_image=docker.io/curlimages/curl:latest

oc run curl -it --rm --image="${curl_image}" --command sh --overrides '{
  "spec": {
    "securityContext": {
      "privileged": false,
      "allowPrivilegeEscalation": false,
      "runAsNonRoot": true,
      "seccompProfile": {
        "type": "RuntimeDefault"
      }
    }
  }
}'


oc run curl -it --image="${curl_image}" --rm --command sh \
  --overrides '{
      "spec": {
        "serviceAccountName": "default",
        "securityContext": {
          "privileged": false,
          "allowPrivilegeEscalation": false,
          "runAsNonRoot": true,
          "seccompProfile": {
            "type": "RuntimeDefault"
          }
        }
      }
    }'