# OpenShift Virtualization

Expects to run on AWS IPI.

Deploys a MachineSet using a `metal` instance type in AWS and configures VMs to run only on those machines.

## Container Disks
- https://quay.io/organization/containerdisks

## Windows

Some initial attempts to get Windows VMs working.

- Kubevirt template: <https://github.com/kubevirt/common-templates/blob/master/templates/windows2k22.tpl.yaml>
- Get Windows Server 2022 images: <https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2022>

```bash
# convert VHD to QCOW2
qemu-img convert win2022.vhd -O qcow2 win2022.qcow2

# upload as data source
virtctl image-upload dv win2022-dv \
    --namespace openshift-virtualization-os-images \
    --uploadproxy-url=https://cdi-uploadproxy-openshift-cnv.apps.ipi.aws.joshgav.com/ \
    --size=10Gi \
    --image-path=/home/joshgav/tmp/win2022.qcow2 \
    --force-bind
```