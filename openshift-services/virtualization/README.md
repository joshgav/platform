# OpenShift Virtualization

- `deploy.sh` expects to run on AWS IPI; it creates a MachineSet for `metal` machines for VMs to run on.
- `windows.sh` sets up a generic Windows 2022 disk on the local machine then uploads it to the cluster.

## Container Disks
- https://quay.io/organization/containerdisks

## Windows Resources
- Get Windows Server 2022 images: <https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2022>
- https://cloud.redhat.com/blog/creating-a-windows-base-image-for-openshift
    - https://github.com/RHsyseng/cnv-integration/tree/main/blogs/windows-unattended
- https://github.com/kubevirt/common-templates/blob/master/templates/windows2k22.tpl.yaml
- https://palant.info/2023/02/13/automating-windows-installation-in-a-vm/
- Convert a VHD to QCOW2
  ```bash
  qemu-img convert win2022.vhd -O qcow2 win2022.qcow2
  ```
  