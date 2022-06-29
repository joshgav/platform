#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

${this_dir}/deploy-operator.sh

source ${root_dir}/lib/aws.sh
echo "INFO: finding Route53 zone ID for ${OPENSHIFT_BASE_DOMAIN}"
export ROUTE53_ZONE_ID=$(hosted_zone_id "${OPENSHIFT_BASE_DOMAIN}.")

echo "INFO: prerender manifests"
for file in $(dir ${this_dir}/aws/*.yaml.tpl); do 
    # echo "INFO: rendering ${file} to ${file%%'.tpl'}"
    cat "${file}" | envsubst > "${file%%'.tpl'}"
done
for file in $(dir ${this_dir}/openshift/*.yaml.tpl); do 
    # echo "INFO: rendering ${file} to ${file%%'.tpl'}"
    cat "${file}" | envsubst > "${file%%'.tpl'}"
done

echo "INFO: install issuers and certificates for AWS"
kustomize build ${this_dir}/aws | oc apply -f -

echo "INFO: install issuers and certificates for OpenShift"
kustomize build ${this_dir}/openshift | oc apply -f -

kubectl patch --type=merge ingresscontrollers.operator.openshift.io default \
    --namespace openshift-ingress-operator \
    --patch-file ${this_dir}/openshift/ingresscontroller_patch.yaml
