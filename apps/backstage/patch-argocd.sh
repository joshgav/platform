#! /usr/bin/env bash

echo "INFO: enable apiKey generation in ArgoCD"
oc patch --type merge -n openshift-gitops argocd openshift-gitops --patch '{"spec": {"extraConfig": {"accounts.admin": "apiKey"}}}'
