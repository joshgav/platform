## Windows VMs on OpenShift

### Windows ISO Downloads

- Server 2025: https://www.microsoft.com/en-us/evalcenter/download-windows-server-2025
- Server 2022: <https://www.microsoft.com/en-us/evalcenter/download-windows-server-2022>
- Windows 11: https://www.microsoft.com/en-us/software-download/windows11

### Resources

- Tekton: <https://github.com/kubevirt/kubevirt-tekton-tasks/tree/main/release>
- OpenShift Templates: <https://github.com/kubevirt/common-templates/tree/master/templates>

### Blogs

- <https://xphyr.net/post/ocpv_installing_windows_from_iso/>
- <https://developers.redhat.com/articles/2024/09/09/create-windows-golden-image-openshift-virtualization>
- <https://www.redhat.com/en/blog/creating-a-golden-image-for-windows-vms-in-openshift-virtualization>
- <https://cloud.redhat.com/blog/creating-a-windows-base-image-for-openshift>
- <https://palant.info/2023/02/13/automating-windows-installation-in-a-vm/>

### Tips
- Convert a VHD to QCOW2
```bash
qemu-img convert win2022.vhd -O qcow2 win2022.qcow2
```

- Upload an image
```bash
virtctl image-upload dv win2k22-iso \
    --image-path ./win2022-2024-04-02.iso \
    --namespace openshift-virtualization-os-images \
    --size 10Gi \
    --force-bind
```
