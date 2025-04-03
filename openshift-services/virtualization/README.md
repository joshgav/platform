# OpenShift Virtualization

- Docs: <https://docs.redhat.com/en/documentation/openshift_container_platform/4.16/html/virtualization>

Expects to run on AWS IPI. For ROSA, create a Node Pool with `metal` instance
types using the [rosa CLI](https://github.com/openshift/rosa).

`./create-machinesets.sh` deploys MachineSets using a `metal` instance type in
AWS. See `./operand/machineset-example.yaml` for an example.

## Nested Virtualization

- see <https://access.redhat.com/solutions/6692341>
- set defaultCPUModel: <https://docs.redhat.com/en/documentation/openshift_container_platform/4.13/html/virtualization/virtual-machines#virt-configuring-default-cpu-model>

## Other tips
- An invalid `storageprofile` may be created for the Noobaa storageclass. If so
  delete it with `oc delete storageprofiles.cdi.kubevirt.io noobaa.noobaa.io`. See
  <https://bugzilla.redhat.com/show_bug.cgi?id=2169686> for info.
- Container disks are published at <https://quay.io/organization/containerdisks>
