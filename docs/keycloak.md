## Keycloak

### Tips

To retrieve a token for a user directly from Keycloak, first enable "Direct
Access Grants". In the Web UI this is in Clients -> Settings.

Then call the `/token` endpoint as follows, replacing the env vars
appropriately. Use an LDAP or other identity for the user, and a Keycloak client
for the ID and secret.

```bash
user_name=${user_name}
user_password=${user_password}
client_id=${client_id}
client_secret=${client_secret}
keycloak_hostname=${keycloak_hostname}

curl --insecure -L -X POST "https://${keycloak_hostname}/auth/realms/app/protocol/openid-connect/token" \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode "grant_type=password" \
    --data-urlencode "client_id=${client_id}" \
    --data-urlencode "client_secret=${client_secret}" \
    --data-urlencode "scope=openid" \
    --data-urlencode "username=${user_name}" \
    --data-urlencode "password=${user_password}"
```