# instructions here: https://docs.redhat.com/en/documentation/migration_toolkit_for_virtualization/2.8/html/installing_and_using_the_migration_toolkit_for_virtualization/prerequisites_mtv#creating-vddk-image_mtv
# rough set of commands to run to create an image in the local OpenShift registry

oc project default
oc adm policy add-role-to-user -n default -z default registry-editor
oc run -n default --privileged -it --rm bash --image registry.access.redhat.com/ubi9/ubi:latest -- bash
## inside pod:
dnf install podman
mkdir vddk && cd vddk
## follow instructions to download VDDK and create Containerfile at
## https://docs.redhat.com/en/documentation/migration_toolkit_for_virtualization/2.8/html/installing_and_using_the_migration_toolkit_for_virtualization/prerequisites_mtv#creating-vddk-image_mtv
podman build . -t image-registry.openshift-image-registry.svc:5000/default/vddk:latest
podman login --tls-verify=false image-registry.openshift-image-registry.svc:5000 -u default -p $(cat /run/secrets/kubernetes.io/serviceaccount/token)
podman push --tls-verify=false image-registry.openshift-image-registry.svc:5000/default/vddk:latest
