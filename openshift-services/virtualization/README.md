# OpenShift Virtualization

Expects to run on AWS IPI. For ROSA, create a Node Pool with `metal` instance
types using the [rosa CLI](https://github.com/openshift/rosa).

`./deploy.sh` Deploys a MachineSet using a `metal` instance type in AWS and
configures VMs to run only on those machines.

## Windows

Some info related to running Windows images.

- Get Windows Server 2022 images: <https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2022>
- Kubevirt template for Win2k22: <https://github.com/kubevirt/common-templates/blob/master/templates/windows2k22.tpl.yaml>
- Blog post on creating an image for Win2k19: <https://cloud.redhat.com/blog/creating-a-windows-base-image-for-openshift>
    - Related git repo: <https://github.com/RHsyseng/cnv-integration/tree/main/blogs/windows-unattended>
- Another post: <https://palant.info/2023/02/13/automating-windows-installation-in-a-vm/>
- Convert a VHD to QCOW2
  ```bash
  qemu-img convert win2022.vhd -O qcow2 win2022.qcow2
  ```
- Upload an image
  ```bash
  virtctl image-upload dv win2022-dv \
      --namespace openshift-virtualization-os-images \
      --uploadproxy-url=https://cdi-uploadproxy-openshift-cnv.apps.ipi.aws.joshgav.com/ \
      --size=10Gi \
      --image-path=/home/joshgav/tmp/win2022.qcow2 \
      --force-bind
  ```

## Other tips
- An invalid `storageprofile` may be created for the Noobaa storageclass. If so
  delete it with `oc delete storageprofiles.cdi.kubevirt.io noobaa.noobaa.io`. See
  <https://bugzilla.redhat.com/show_bug.cgi?id=2169686> for info.
- Container disks are published at <https://quay.io/organization/containerdisks>
