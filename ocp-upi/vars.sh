#! /usr/bin/env bash

if [[ ! -v root_dir ]]; then
    export root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
fi
source ${root_dir}/common/vars.sh

arch=${ARCH:-x86_64}
plat=${PLAT:-linux}
openshift_downloads_baseurl=${OPENSHIFT_DOWNLOADS_BASEURL:-https://mirror.openshift.com/pub/openshift-v4}

## ocp (OpenShift)
# e.g. '4.9' or '' for latest
ocp_minor_version=${OCP_MINOR_VERSION:-''}
ocp_channel_names=("stable" "fast" "latest" "candidate")
# default to latest
ocp_channel=${OCP_CHANNEL_NAME:-${ocp_channel_names[2]}}
ocp_baseurl=${openshift_downloads_baseurl}/${arch}/clients/ocp/${ocp_channel}${ocp_minor_version:+"-"}${ocp_minor_version}

export ocp_client_url=${ocp_baseurl}/openshift-client-${plat}.tar.gz
export ocp_install_url=${ocp_baseurl}/openshift-install-${plat}.tar.gz
export ocp_releasetxt_url=${ocp_baseurl}/release.txt

## coreos-installer
coreos_installer_version=${CORE_INSTALLER_VERSION:-latest}
export coreos_installer_url=${openshift_downloads_baseurl}/${arch}/clients/coreos-installer/${coreos_installer_version}/coreos-installer

## rhcos (CoreOS)
# TODO: the following are two different levels in the directory hierarchy. need to clarify their meaning
rhcos_version_minor=${RHCOS_VERSION_MINOR:-'4.9'}
rhcos_version_patch=${RHCOS_VERSION_PATCH:-'4.9.0'}
rhcos_baseurl=${openshift_downloads_baseurl}/${arch}/dependencies/rhcos/${rhcos_version_minor}/${rhcos_version_patch}

# kernel/initramfs/rootfs disg images
export rhcos_installer_image_urls=()
export rhcos_live_image_urls=()
for image_type in "initramfs" "kernel" "rootfs"; do
    export rhcos_installer_image_urls+=(${rhcos_baseurl}/rhcos-installer-${image_type}.${arch}.img)
    export rhcos_live_image_urls+=(${rhcos_baseurl}/rhcos-live-${image_type}.${arch}.img)
done

# iso image for SNO
export rhcos_live_iso_url=${rhcos_baseurl}/rhcos-live.${arch}.iso