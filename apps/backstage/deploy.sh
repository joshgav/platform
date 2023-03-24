#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

export bs_app_name=${1:-${BS_APP_NAME:-bs1}}
export quay_user_name=${2:-${QUAY_USER_NAME:-${USER}}}

export openshift_ingress_domain=$(oc get ingresses.config.openshift.io cluster -ojson | jq -r .spec.domain)

# backstage_version='1.11.0'
# nvm use --lts --latest
# npx "@backstage/create-app@latest" --path "${bs_app_name}"

if [[ "${REBUILD_IMAGE}" == "1" ]]; then
    cp -r overlay/* ${bs_app_name}
    echo "INFO: build & push quay.io/${quay_user_name}/${bs_app_name}-backstage"
    pushd ${bs_app_name}
        yarn install
        yarn tsc
        yarn build:all
        yarn build-image
        docker tag backstage:latest quay.io/${quay_user_name}/${bs_app_name}-backstage:latest
        docker push quay.io/${quay_user_name}/${bs_app_name}-backstage:latest
    popd
fi

ensure_namespace backstage
kubectl config set-context --current --namespace backstage

## TODO: test further, fix image and avoid this
oc adm policy add-scc-to-user --serviceaccount=default nonroot-v2
oc adm policy add-cluster-role-to-user --serviceaccount=default view

echo ""
echo "INFO: apply resources from ${this_dir}/base/*.yaml"
for file in $(ls ${this_dir}/base/*.yaml); do
    lines=$(cat ${file} | awk '/^[^#].*$/ {print}' | wc -l)
    if [[ ${lines} > 0 ]]; then
        cat ${file} | envsubst '${bs_app_name}' | kubectl apply -f -
    fi
done

echo ""
file_path=${this_dir}/${bs_app_name}.app-config.yaml
if [[ -e "${file_path}" ]]; then
    echo "INFO: applying appconfig configmap from ${file_path}"

    kubectl delete configmap ${bs_app_name}-backstage-app-config 2> /dev/null

    tmpfile=$(mktemp)
    cat "${file_path}" | envsubst '${bs_app_name} ${quay_user_name} ${openshift_ingress_domain} ${ARGOCD_USERNAME} ${ARGOCD_PASSWORD}' > ${tmpfile}
    kubectl create configmap ${bs_app_name}-backstage-app-config \
        --from-file "$(basename ${file_path})=${tmpfile}"
else
    echo "INFO: no file found at ${file_path}"
fi

echo ""
github_app_creds_path=${this_dir}/github-app-credentials.yaml
if [[ -e ${github_app_creds_path} ]]; then
    echo "INFO: applying github-app-credentials.yaml as a secret"

    kubectl delete secret github-app-credentials 2> /dev/null
    kubectl create secret generic github-app-credentials --from-file=github-app-credentials.yaml
fi

oc create clusterrolebinding backstage-backend-k8s --clusterrole=backstage-k8s-plugin --serviceaccount=backstage:default
oc create clusterrolebinding backstage-backend-ocm --clusterrole=backstage-ocm-plugin --serviceaccount=backstage:default

echo ""
echo "INFO: helm upgrade --install"
ensure_helm_repo bitnami https://charts.bitnami.com/bitnami 1> /dev/null
ensure_helm_repo backstage https://backstage.github.io/charts 1> /dev/null
cat "${this_dir}/${bs_app_name}.chart-values.yaml" | \
    envsubst '${bs_app_name} ${quay_user_name}  ${openshift_ingress_domain}' | \
        helm upgrade --install ${bs_app_name} backstage/backstage --values -

echo ""
echo "INFO: Visit your Backstage instance at https://${bs_app_name}-backstage-backstage.${openshift_ingress_domain}/"
echo ""
