## Use virt-manager

How to use virt-manager GUI to connect to KVM host via SSH.

Copy SSH key (`ssh-copy-id`) to KVM host, e.g., `ssh-copy-id -i ~/.ssh/id_joshgav_rsa.pub lab-user@147.28.229.177`

On KVM host ensure login user is part of libvirt group:

```bash
USER_NAME=lab-user
usermod -aG libvirt ${USER_NAME}
```
