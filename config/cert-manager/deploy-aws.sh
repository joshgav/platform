#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

source ${root_dir}/lib/aws.sh
source ${root_dir}/lib/requirements.sh

install_cmctl

## Prefer Helm chart via cmctl CLI over subscription to operator, because Helm chart/cmctl can be modified.
## We modify the nameservers used for DNS01 ACME checks to ensure they work on AWS.
if ! cmctl check api &> /dev/null; then
    echo "INFO: cert-manager not discovered, attempting to install"
    cmctl experimental install \
        --namespace cert-manager \
        --set extraArgs={'--dns01-recursive-nameservers=8.8.8.8:53,8.8.4.4:53'}
else
    echo "INFO: cert-manager already installed"
fi

echo "INFO: applying access key secret for route53 DNS01 config"
oc apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
    name: route53-access-key
    namespace: cert-manager
stringData:
    AccessKeyID: ${AWS_ACCESS_KEY_ID}
    AccessKeySecret: ${AWS_SECRET_ACCESS_KEY}
EOF

echo "INFO: finding public hosted zone ID for ${OPENSHIFT_BASE_DOMAIN}"
export zone_id=$(hosted_zone_id "${OPENSHIFT_BASE_DOMAIN}.")

echo "INFO: prerender manifests"
for file in $(dir ${this_dir}/aws/*.yaml.tpl); do 
    echo "rendering ${file} to ${file%%'.tpl'}"
    cat "${file}" | envsubst > "${file%%'.tpl'}"
done

echo "INFO: render and apply manifests"
kustomize build ${config_path} | oc apply -f -
