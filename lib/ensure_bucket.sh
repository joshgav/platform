function ensure_bucket {
    local bucket_name=${1}
    local bucket_namespace=${2}
    local external_endpoint_url=${3:-"false"}

    oc apply -f - <<EOF
        apiVersion: objectbucket.io/v1alpha1
        kind: ObjectBucketClaim
        metadata:
            name: ${bucket_name}-claim
            namespace: ${bucket_namespace}
        spec:
            bucketName: ${bucket_name}
            storageClassName: openshift-storage.noobaa.io
EOF

    bucket_phase='Pending'
    while [[ "${bucket_phase}" != "Bound" ]]; do
        echo "INFO: awaiting binding of bucket claim ${bucket_name}-claim"
        bucket_phase=$(oc get objectbucketclaim -n ${bucket_namespace} ${bucket_name}-claim -ojson | jq -r '.status.phase')
    done
    echo "INFO: bucket claim ${bucket_name}-claim bound"

    secret_exists=1
    while [[ "${secret_exists}" != 0 ]]; do
        oc get secret -n ${bucket_namespace} ${bucket_name}-claim &> /dev/null
        secret_exists=$?
    done

    if [[ "${external_endpoint_url}" == "true" ]]; then
        # external DNS
        export S3_ENDPOINT_URL=$(oc get -n openshift-storage noobaas noobaa -ojson | jq -r '.status.services["serviceS3"].externalDNS[0]')
    else
        # internal DNS
        export S3_ENDPOINT_URL=$(oc get -n openshift-storage noobaas noobaa -ojson | jq -r '.status.services["serviceS3"].internalDNS[0]')
    fi
    export S3_ACCESS_KEY_ID=$(oc get secret -n ${bucket_namespace} ${bucket_name}-claim -ojson | jq -r '.data.AWS_ACCESS_KEY_ID | @base64d')
    export S3_SECRET_ACCESS_KEY=$(oc get secret -n ${bucket_namespace} ${bucket_name}-claim -ojson | jq -r '.data.AWS_SECRET_ACCESS_KEY | @base64d')
    export S3_BUCKET_NAME=${bucket_name}

    echo 'INFO: bucket values:
        S3_ENDPOINT_URL: ${S3_ENDPOINT_URL}
        S3_ACCESS_KEY_ID: ${S3_ACCESS_KEY_ID}
        S3_BUCKET_NAME: ${S3_BUCKET_NAME}
    ' | envsubst
}
