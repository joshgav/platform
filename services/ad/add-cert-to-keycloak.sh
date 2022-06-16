#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

namespace=app

oc create secret generic adfs-cert --from-file ${this_dir}/adfs.cer -n ${namespace}

## details at https://access.redhat.com/solutions/6164982
# TODO: automate as patches
#
# set Keycloak operand spec.unmanaged=true
#
# patch Keycloak StatefulSet as follows
# - mount cert as volume
# - add path to X509_CA_BUNDLE
#
# ----
# kind: StatefulSet
# apiVersion: apps/v1
# metadata:
#   name: keycloak
# spec:
#   template:
#     spec:
#       containers:
#         - name: keycloak
#           env:
#             - name: X509_CA_BUNDLE
#               value: >-
#                 /var/run/secrets/kubernetes.io/serviceaccount/*.crt
#                 /etc/adfs/adfs.cer
#           volumeMounts:
#             - name: adfs-cert
#               readOnly: true
#               mountPath: /etc/adfs
#       volumes:
#         - name: adfs-cert
#           secret:
#             secretName: adfs-cert
#             defaultMode: 420