# OpenShift

This is a collection of resources to help get started installing OpenShift on bare metal. Some resources are oriented to Single-Node OpenShift (SNO) in particular.

The scripts here are work in progress.

## Resources

- Install SNO: https://docs.openshift.com/container-platform/4.10/installing/installing_sno/install-sno-installing-sno.html
- https://github.com/eranco74/bootstrap-in-place-poc

## OpenShift on libvirtd

- Install OKD on libvirt: https://github.com/openshift/okd/blob/master/Guides/UPI/libvirt/libvirt.md
- OpenShift installer with libvirt: https://github.com/openshift/installer/tree/master/docs/dev/libvirt

- https://www.redhat.com/en/blog/installing-openshift-41-using-libvirt-and-kvm
- https://computingforgeeks.com/how-to-deploy-openshift-container-platform-on-kvm/
- https://luis-javier-arizmendi-alonso.medium.com/deploying-an-openshift-4-lab-in-a-kvm-node-using-libvirt-ipi-652f0476e8a5
- https://openshift-kni.github.io/baremetal-deploy/

- https://docs.openshift.com/container-platform/4.9/architecture/architecture-installation.html
- https://docs.openshift.com/container-platform/4.9/installing/installing_bare_metal/preparing-to-install-on-bare-metal.html
- https://docs.openshift.com/container-platform/4.9/installing/installing_bare_metal/installing-bare-metal.html

## Troubleshooting

  set `security_driver = 'none'` in `/etc/libvirt/qemu.conf`
- https://github.com/openshift/installer/blob/master/docs/dev/alternative_release_image_sources.md
  - latest release: https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/release.txt
- Ensure dynamic pod interfaces are excluded from NetworkManager management. In the `[keyfile]` section of NetworkManager.conf or /etc/NetworkManager/conf.d/* use the `unmanaged-devices` key.
- okay to ignore: `overlayfs: unrecognized mount option "volatile" or missing value`
- okay to ignore: `failed to get container stats`: https://github.com/kubernetes/kubernetes/issues/56850
- okay to ignore: storageError when acquiring lease