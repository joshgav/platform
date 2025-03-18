## Nginx Setup

How to configure nginx as a reverse proxy for a libvirt-hosted SNO cluster.

Docs: <https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/deploying_web_servers_and_reverse_proxies/setting-up-and-configuring-nginx_deploying-web-servers-and-reverse-proxies>

### Install nginx on RHEL

Set these:

```
setsebool -P httpd_can_network_connect 1
semanage port -a -t http_port_t -p tcp 6443
```

Follow these instructions: <https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/deploying_web_servers_and_reverse_proxies/setting-up-and-configuring-nginx_deploying-web-servers-and-reverse-proxies>

```
dnf module list nginx
dnf module enable nginx:1.24
dnf install nginx

systemctl enable nginx
systemctl start nginx
```

Test connectivity by navigating to <http://equinix.joshgav.com/>.

### Create a CA

```bash
CA_NAME=ca.joshgav.com

## generate the private key
openssl genrsa -out ${CA_NAME}.key -des3 2048

## create and self-sign the corresponding public key as a CA
openssl req -x509 -new -subj "/CN=${CA_NAME}" \
    -key ${CA_NAME}.key -sha256 -days 36500 -out ${CA_NAME}.crt \
    --addext "basicConstraints=critical,CA:TRUE"
```

### Create a server certificate

Note: Wildcard SANs seem to only go one level deep, so additional domains should
be added for OpenShift `apps...` domains.

Contents of equinix.joshgav.com.cnf:

```text
subjectAltName     = @alt_names
extendedKeyUsage   = serverAuth,clientAuth

[alt_names]
DNS.1   = equinix.joshgav.com
DNS.2   = *.equinix.joshgav.com
DNS.3   = api.sno1.equinix.joshgav.com
DNS.4   = *.apps.sno1.equinix.joshgav.com
```

```bash
SERVER_NAME=equinix.joshgav.com
CA_NAME=ca.joshgav.com

## generate the private key
openssl genrsa -out ${SERVER_NAME}.key 2048
## generate a pubkey and CSR for the server cert
openssl req -new -subj "/CN=${SERVER_NAME}" \
    -key ${SERVER_NAME}.key -out ${SERVER_NAME}.csr \
    -addext 'extendedKeyUsage=serverAuth,clientAuth'
## approve/sign the server cert with the CA cert
openssl x509 -req -days 36500 -CA ${CA_NAME}.crt -CAkey ${CA_NAME}.key \
    -in ${SERVER_NAME}.csr -out ${SERVER_NAME}.crt \
    -extfile ${SERVER_NAME}.cnf
```

### Check the contents of a certificate

```
openssl x509 -in path/to/cert.crt -text 
```

### Copy files to http host:

```
/usr/share/nginx/pki/equinix.joshgav.com.crt
/usr/share/nginx/pki/equinix.joshgav.com.key
```

### Retrive CA cert from cluster

Copy server certificate followed by CA certificate into files to be referenced from `nginx.conf` files.

```
openssl s_client -connect api.sno1.equinix.joshgav.com:6443 \
    -servername api.sno1.equinix.joshgav.com \
    -showcerts

openssl s_client -connect console-openshift-console.apps.sno1.equinix.joshgav.com:443 \
    -servername console-openshift-console.apps.sno1.equinix.joshgav.com \
    -showcerts
```

```
/usr/share/nginx/pki/apps.sno1.equinix.joshgav.com.crt
/usr/share/nginx/pki/api.sno1.equinix.joshgav.com.crt
```

### `server` block for direct TLS

You may edit these blocks in `/etc/nginx/nginx.conf` or add as additional files in `/etc/nginx/conf.d`.

If you add files to conf.d the outermost block will be a `server` block - not an `http` block.

After modifying files, be sure to restart nginx: `systemctl restart nginx.service`


```
server {
    listen       443 ssl;
    listen       [::]:443 ssl;
    server_name  equinix.joshgav.com;
    root         /usr/share/nginx/html;

    ssl_certificate "/usr/share/nginx/pki/equinix.joshgav.com.crt";
    ssl_certificate_key "/usr/share/nginx/pki/equinix.joshgav.com.key";
    ssl_session_cache shared:SSL:1m;
    ssl_session_timeout  10m;
    ssl_prefer_server_ciphers on;

    error_page 404 /404.html;
    location = /404.html {
    }

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
    }
}
```

### server block for proxied TLS + SNI for apps

```
server {
    listen       443 ssl;
    listen       [::]:443 ssl;
    server_name  *.apps.sno1.equinix.joshgav.com;

    ssl_certificate "/usr/share/nginx/pki/equinix.joshgav.com.crt";
    ssl_certificate_key "/usr/share/nginx/pki/equinix.joshgav.com.key";
    ssl_session_cache shared:SSL:1m;
    ssl_session_timeout  10m;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_set_header Host $http_host;
        proxy_ssl_server_name on;
        proxy_ssl_name $http_host;
        proxy_pass https://192.168.126.10:443;
        proxy_ssl_trusted_certificate /usr/share/nginx/pki/apps.sno1.equinix.joshgav.com.crt;
        proxy_http_version 1.1;
    }
}
```

### server block for proxied TLS + SNI for API

```
server {
    listen       6443 ssl;
    listen       [::]:6443 ssl;
    server_name  api.sno1.equinix.joshgav.com;

    ssl_certificate "/usr/share/nginx/pki/equinix.joshgav.com.crt";
    ssl_certificate_key "/usr/share/nginx/pki/equinix.joshgav.com.key";
    ssl_session_cache shared:SSL:1m;
    ssl_session_timeout  10m;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_set_header Host $http_host;
        proxy_ssl_server_name on;
        proxy_ssl_name $http_host;
        proxy_pass https://192.168.126.10:6443;
        proxy_ssl_trusted_certificate /usr/share/nginx/pki/api.sno1.equinix.joshgav.com.crt;
        proxy_http_version 1.1;
    }
}
```

### Resources

- https://nginx.org/en/docs/http/ngx_http_proxy_module.html
- https://nginx.org/en/docs/http/ngx_http_core_module.html
- https://nginx.org/en/docs/http/ngx_http_ssl_module.html
- https://docs.nginx.com/nginx/admin-guide/security-controls/securing-http-traffic-upstream
- https://reinout.vanrees.org/weblog/2017/05/02/https-behind-proxy.html