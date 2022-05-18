## ADFS

Endpoint URLs to provide in Keycloak OIDC provider form for ADFS:

```
adfs_hostname=adfs.aws.joshgav.com

metadata_endpoint=https://adfs.aws.joshgav.com/adfs/.well-known/openid-configuration
authorize_endpoint=https://${adfs_hostname}/adfs/oauth2/authorize/
token_endpoint=https://adfs.aws.joshgav.com/adfs/oauth2/token/
userinfo_endpoint=https://adfs.aws.joshgav.com/adfs/userinfo
issuer=https://adfs.aws.joshgav.com/adfs
```