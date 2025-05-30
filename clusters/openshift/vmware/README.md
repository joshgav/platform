# Install on VMware

## Resources
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html-single/installing_on_vmware_vsphere/index
- https://github.com/openshift/installer/tree/main/docs/user/vsphere
- https://examples.openshift.pub/cluster-installation/vmware/
- https://examples.openshift.pub/cluster-installation/vmware/agent-base-non-integrated/
- https://medium.com/@prayag-sangode/openshift-installation-on-vmware-97e596ef5e97

```txt
## Enable — disk.EnableUUID

To enable disk.EnableUUID, you can use the vSphere Client or the vSphere API. The following steps will show you how to enable disk.EnableUUID using the vSphere Client:

1. Open the vSphere Client and connect to the ESXi host that hosts the VM.Power off the VM.
1. Right-click the VM and select Edit Settings.
1. Click the VM Options tab.
1. Click the Advanced button.
1. Click Edit Configuration in the Configuration Parameters section.
1. Click Add Row.
1. In the Key column, type disk.EnableUUID.
1. In the Value column, type TRUE.
1. Click OK and then Save.
```