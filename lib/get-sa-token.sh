#! /usr/bin/env bash

function get_serviceaccount_token {
    local serviceaccount_name=${1:-default}
    local serviceaccount_namespace=${2:-default}

    token_secret_name=sa-token-${serviceaccount_name}-${RANDOM}
    kubectl apply -f - &> /dev/null <<EOF
        apiVersion: v1
        kind: Secret
        metadata:
            name: ${token_secret_name}
            namespace: ${serviceaccount_namespace}
            annotations:
                "kubernetes.io/service-account.name": "${serviceaccount_name}"
        type: kubernetes.io/service-account-token
EOF
    if [[ $? != 0 ]]; then
        >&2 echo "failed to create/apply token secret"
        return 2
    fi

    sleep 1
    kubectl get secret ${token_secret_name} \
        --namespace ${serviceaccount_namespace} \
        --output go-template="{{ .data.token | base64decode }}"
}
export get_serviceaccount_token