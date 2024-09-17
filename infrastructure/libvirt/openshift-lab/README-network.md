## Network Config

### resources

- port forwarding and DNAT: https://access.redhat.com/solutions/7041327
- https://libvirt.org/firewall.html

### firewalld

Install firewalld: `dnf install firewalld`

Configure firewalld before enabling it:

```bash
# adds service to current default zone (default public)
firewall-offline-cmd --add-service=ssh
# adds interface to named zone
firewall-offline-cmd --add-interface=${IF_NAME} --zone=${ZONE_NAME}
firewall-offline-cmd --add-interface=bond0 --zone=external
# alternatively using nmcli
nmcli connection modify ${IF_NAME} connection.zone ${ZONE_NAME}
nmcli connection modify bond0 connection.zone external
```

### nginx

- https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/deploying_web_servers_and_reverse_proxies/setting-up-and-configuring-nginx_deploying-web-servers-and-reverse-proxies

```
setsebool -P httpd_can_network_connect 1
```

### libvirt

```
firewall-cmd --zone=libvirt --add-interface virbr1
firewall-cmd --zone=libvirt --add-service https
nft add rule ip nat PREROUTING iifname "bond0" tcp dport 443 dnat to 192.168.126.10
nft add rule ip nat PREROUTING iifname "bond0" tcp dport 6443 dnat to 192.168.126.10
```