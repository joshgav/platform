## MTV

### Docs

- https://access.redhat.com/documentation/en-us/migration_toolkit_for_virtualization/
- https://github.com/kubev2v/forklift
- https://github.com/kubev2v/forklift-documentation/

### Tips

- The secret with credentials for the VMware Provider CR includes a `thumbprint` key. This should be the SHA1 thumbprint of the TLS certificate served for the vCenter API. See <https://www.libguestfs.org/nbdkit-vddk-plugin.1.html#THUMBPRINTS> for several methods of getting the thumbprint. One way is by running the following command against the vCenter hostname:

```bash
VCENTER_HOSTNAME=vcsrs01-vc.infra.demo.redhat.com
openssl s_client -connect ${VCENTER_HOSTNAME}:443 < /dev/null | openssl x509 -in /dev/stdin -fingerprint -sha1 -noout
```

