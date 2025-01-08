## Forwarding and Load Balancing

### Forward Internet traffic directly to VM with nftables

Forward traffic from host on public Internet to VM.
Masquerade rules for traffic outbound from the VM are already created by libvirt.

```bash
nft insert rule ip filter LIBVIRT_FWI tcp dport 443 accept
nft insert rule ip filter LIBVIRT_FWI tcp dport 6443 accept
nft add chain ip nat PREROUTING { type nat hook prerouting priority -100 \; }
nft add rule ip nat PREROUTING iifname "bond0" tcp dport 443 dnat to 192.168.126.10
nft add rule ip nat PREROUTING iifname "bond0" tcp dport 6443 dnat to 192.168.126.10
```

It is not supported to redirect traffic from a different port to 6443 for the
api endpoint, but it is possible, see
<https://access.redhat.com/solutions/4665121>. Be sure to change kubeconfig or
the `oc login --server` parameter to the redirected port.

```bash
nft add rule ip nat PREROUTING iifname "bond0" tcp dport 10443 dnat to 192.168.126.10:6443
```

It is possible to change the port the router listens on, see
<https://access.redhat.com/solutions/6784921>, but internal redirects (e.g., for
OAuth login) won't include the port in the URL.