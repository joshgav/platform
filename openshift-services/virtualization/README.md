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
- To enable old OS's: https://access.redhat.com/solutions/6571471
```bash
oc annotate --overwrite -n openshift-cnv hco kubevirt-hyperconverged kubevirt.kubevirt.io/jsonpatch='[
  {"op": "add", "path": "/spec/configuration/architectureConfiguration", "value": {} },  
  {"op": "add", "path": "/spec/configuration/architectureConfiguration/amd64", "value": {} },
  {"op": "add", "path": "/spec/configuration/architectureConfiguration/amd64/emulatedMachines", "value": ["q35*", "pc-q35*", "pc-i440fx-rhel7.6.0"] }
]'
```
- To check: `oc get kv kubevirt-kubevirt-hyperconverged -n openshift-cnv -o yaml | grep -A 3 emulate`