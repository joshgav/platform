# setup_workdir preps a dir to store working state
# if no dir exists create one
# if dir exists depend on env vars
#   - if none set - emit warning and `exit 2`
#   - if RESUME set - use existing dir
#   - if OVERWRITE set - reset dir
function setup_workdir {
    local workdir=${1:-"${this_dir:-'.'}/_workdir"}

    if [[ -e ${workdir} && -z "${RESUME}" && -z "${OVERWRITE}" ]]; then
        echo "WARNING: workdir already exists, set OVERWRITE=1 to remove or RESUME=1 to continue"
        exit 2
    elif [[ -e ${workdir} && -n "${RESUME}" ]]; then
        echo "INFO: continuing from existing workdir"
    elif [[ -e ${workdir} && -n "${OVERWRITE}" ]]; then
        rm -rf ${workdir}
        mkdir -p "${workdir}"
    else
        mkdir -p "${workdir}"
    fi
}

# ensure_ssh_keypair ensures an RSA SSH keypair exists in the specified directory
function ensure_ssh_keypair {
    keypair_path=${1:-"${root_dir:-'.'}/.ssh"}

    mkdir -p "${keypair_path}"
    if [[ ! -e "${keypair_path}/id_rsa" ]]; then
        ssh-keygen -t rsa -b 4096 -C "user@openshift" -f "${keypair_path}/id_rsa" -N ''
    fi
}

# is_openshift returns 0 if cluster appears to be OpenShift
function is_openshift() {
    set +e
    kubectl get namespaces openshift-operators &> /dev/null
    if [[ $? != 0 ]]; then
        return 1
    fi
    return 0
}

# create_subscription registers a subscription to an operator by packagemanifest name
# by default the subscription is registered in the cluster's default operator namespace
#   for the operator's default channel
function create_subscription() {
    if is_openshift; then
        DEFAULT_OPERATOR_NAMESPACE=openshift-operators
    else
        DEFAULT_OPERATOR_NAMESPACE=operators
    fi

    operator_name=${1}
    operator_namespace=${2:-${DEFAULT_OPERATOR_NAMESPACE}}
    operator_channel=${3}

    package_manifest=$(kubectl get packagemanifests ${operator_name} --output json)
    catalog_name=$(echo ${package_manifest} | jq -r '.status.catalogSource')
    catalog_namespace=$(echo ${package_manifest} | jq -r '.status.catalogSourceNamespace')
    default_channel=$(echo ${package_manifest} | jq -r '.status.defaultChannel')
    if [[ -z "${operator_channel}" ]]; then
        operator_channel=${default_channel}
    fi
    starting_csv=$(echo ${package_manifest} | jq -r ".status.channels[] | select(.name == \"${operator_channel}\") | .currentCSV")

    kubectl apply -f - <<EOF
        apiVersion: operators.coreos.com/v1alpha1
        kind: Subscription
        metadata:
            name: ${operator_name}
            namespace: ${operator_namespace}
        spec:
            channel: ${operator_channel}
            installPlanApproval: Automatic
            name: ${operator_name}
            source: ${catalog_name}
            sourceNamespace: ${catalog_namespace}
            startingCSV: ${starting_csv}
EOF
}

# create_local_operatorgroup creates a namespace-local operatorgroup targeting
# the selfsame namespace
# useful for operators which target only their own namespace
function create_local_operatorgroup {
    local operator_namespace=${1}

    kubectl apply -f - <<EOF
        apiVersion: operators.coreos.com/v1alpha2
        kind: OperatorGroup
        metadata:
            name: local
            namespace: ${operator_namespace}
        spec:
            targetNamespaces:
              - ${operator_namespace}
EOF
}

# create_cluster_operatorgroup 
function create_cluster_operatorgroup {
    local operator_namespace=${1}

    kubectl apply -f - <<EOF
        apiVersion: operators.coreos.com/v1alpha2
        kind: OperatorGroup
        metadata:
            name: ${operator_namespace}-group
            namespace: ${operator_namespace}
EOF
}

function await_resource_ready {
    local resource_name=${1}

    ready=1
    while [[ ${ready} != 0 ]]; do
        echo "INFO: awaiting readiness of operator resource ${resource_name}"
        kubectl api-resources | grep ${resource_name} &> /dev/null
        ready=$?
        if [[ ${ready} != 0 ]]; then sleep 2; else echo "INFO: operator resource ready"; fi
    done
}

function ensure_resource_exists {
    local resource_name=${1}

    await_resource_ready "${resource_name}"
}

function render_yaml {
    local directory=${1:-'.'}

    echo "INFO: rendering env vars in manifests"
    for file in $(find ${directory} -type f -iname '*.tpl'); do 
        echo "DEBUG: rendering ${file} to ${file%%'.tpl'}"
        cat "${file}" | envsubst > "${file%%'.tpl'}"
    done
}

function apply_kustomize_dir {
    local directory=${1:-'.'}

    echo "INFO: rendering and applying kustomize dir ${directory}"
    if [[ -e "${directory}/.env" ]]; then
        echo "INFO: sourcing .env found in kustomize dir"
        set -o allexport
        source ${directory}/.env
        set +o allexport
    fi
    render_yaml "${directory}"
    kustomize build ${directory} | kubectl apply -f -
}

function ensure_namespace {
    local namespace=${1}
    local change_context=${2:-''}

    kubectl get namespace ${namespace} &> /dev/null
    result=$?
    if [[ ${result} != 0 ]]; then
        echo "INFO: namespace ${namespace} not found, attempting to create"
        kubectl create namespace --save-config ${namespace}
        result=$?
    fi
    if [[ ${result} == 0 && -n "${change_context}" ]]; then
        echo "INFO: switching context to namespace ${namespace}"
        kubectl config set-context --current --namespace ${namespace}
        result=$?
    fi
    return ${result}
}

# ensure_helm_repo ensures the repo name exists
# if it doesn't exist it adds it with specified URL
function ensure_helm_repo {
    local name=${1}
    local url=${2}

    repos=($(helm repo list -o json | jq -r '.[].name'))
    echo "${repos[@]}" | grep -wq "${name}"
    result=$?
    if [[ ${result} == 0 ]]; then
        echo "INFO: repo named \"${name}\" already exists"
        helm repo update
        return
    fi
    helm repo add --force-update "${name}" "${url}"
}

# get_cluster_name determines the cluster name part of the ingress domain by stripping
#                  "apps." from the start and the baseDomain from the end of the ingress domain
function get_cluster_name {
    oc get ingresses.config.openshift.io cluster -ojson | jq -r '.spec.domain' | \
        sed 's/^apps\.//' | sed "s/\.${OPENSHIFT_BASE_DOMAIN}//"
}

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
            storageClassName: noobaa.noobaa.io
EOF

    bucket_phase='Pending'
    while [[ "${bucket_phase}" != "Bound" ]]; do
        echo "INFO: awaiting binding of bucket claim ${bucket_name}-claim"
        bucket_phase=$(oc get objectbucketclaim -n ${bucket_namespace} ${bucket_name}-claim -ojson | jq -r '.status.phase')
    done
    echo "INFO: bucket claim ${bucket_name}-claim bound"

    secret_exists=1
    while [[ "${secret_exists}" != 0 ]]; do
        oc get secret ${bucket_name}-claim &> /dev/null
        secret_exists=$?
    done

    if [[ "${external_endpoint_url}" == "true" ]]; then
        # external DNS
        export S3_ENDPOINT_URL=$(oc get -n noobaa noobaas noobaa -ojson | jq -r '.status.services["serviceS3"].externalDNS[0]')
    else
        # internal DNS
        export S3_ENDPOINT_URL=$(oc get -n noobaa noobaas noobaa -ojson | jq -r '.status.services["serviceS3"].internalDNS[0]')
    fi
    export S3_ACCESS_KEY_ID=$(oc get secret ${bucket_name}-claim -ojson | jq -r '.data.AWS_ACCESS_KEY_ID | @base64d')
    export S3_SECRET_ACCESS_KEY=$(oc get secret ${bucket_name}-claim -ojson | jq -r '.data.AWS_SECRET_ACCESS_KEY | @base64d')
    export S3_BUCKET_NAME=${bucket_name}

    echo 'INFO: bucket values:
        S3_ENDPOINT_URL: ${S3_ENDPOINT_URL}
        S3_ACCESS_KEY_ID: ${S3_ACCESS_KEY_ID}
        S3_BUCKET_NAME: ${S3_BUCKET_NAME}
    ' | envsubst
}
