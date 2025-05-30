## Install a SNO cluster in Azure - initial notes
- Create a public DNS Zone or otherwise point the public `api` and `*.apps` names at the public IP address of the SNO VM.
- Create a Private DNS Zone for internal DNS. Add internal records for `api-int`, `api` and `apps.*`.
    - Use `168.63.129.16` as the DNS server address, see <https://learn.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16>
- Create a virtual network with a subnet for the SNO VM. Associate the private DNS zone with this subnet.
- Create a NAT Gateway for outbound traffic from the subnet.
- Create a public IP address to be used by the SNO VM.
- Create a storage account to be used to upload the ISO.
- Create a VM.
- Set a static IP address via the Azure portal after creating the VM
- Download the Discovery ISO and convert it to a VHD. Then upload the VHD as a blob to a storage account. Then add a managed disk based on the uploaded VHD/ISO. Then swap the OS disk of the VM with the Discovery ISO VHD. To convert the ISO use these commands locally before uploading it:
  ```bash
  iso_name=sno01
  size_in_mb=125829120

  qemu-img resize -f raw \
    ${iso_name}.iso ${size_in_mb}
  qemu-img convert -f raw -O vpc -o subformat=fixed,force_size \
    ${iso_name}.iso ${iso_name}.vhd
  ```
  - Note that Azure requires the disk to be an exact multiple of MB (1024^2) so getting the size right is important!
- Create a new disk to be used to install the OS onto. Attach it to the VM.
- Create another new disk to be used for persistent volumes with LVMO. Attach it to the VM.
- Launch the VM and let it boot with the ISO. It will report itself to the Assisted Installer and show up on the Discovery page.
    - During the process you can SSH into the bootstrapping VM with the SSH key provided on the Discovery screen.
- Choose the right disk for the installation disk.
- Start the cluster installation. This will take 30 minutes.
    - During the process you can again SSH into the VM with the SSH key provided on the Discovery screen.
- Once the cluster is installed you can use the kubeconfig file from within the VM. If you've configured public DNS you can also access the console.
- Once the cluster has been installed, swap out the disk for the newly-created one. Shut down the VM then use the following commands:
  ```bash
  group_name=openshift-sno01
  subscription_id=48c192cb-4b83-4023-b1b1-1893e5182f43
  vm_name=master0
  rootdisk_name=sno01-root

  az disk update -g ${group_name} -n ${rootdisk_name} --set osType=Linux
  az disk update -g ${group_name} -n ${rootdisk_name} --set hyperVGeneration=V2
  ## https://learn.microsoft.com/en-us/azure/virtual-machines/linux/os-disk-swap
  az vm update -g ${group_name} -n ${vm_name} \
    --os-disk /subscriptions/${subscription_id}/resourceGroups/${group_name}/providers/Microsoft.Compute/disks/${rootdisk_name}
    ```
- Finally restart the VM with the root disk as OS disk and enjoy your cluster!
