## Noobaa

Noobaa provides ObjectBucketClaim and ObjectBucket resource types.

It also provides an S3 API to consumers.

## Usage

1. Install or update the `noobaa` CLI by using commands in `[install.sh](./install.sh)`
1. Run `deploy.sh`, which will install the noobaa operator, create a PV-backed BackingStore and override the default BucketClass to use it.

## Tips

Access Noobaa buckets via its S3 API as follows:

```bash
export AWS_ACCESS_KEY_ID=$(oc get secret -n noobaa noobaa-admin -ojson | jq -r '.data.AWS_ACCESS_KEY_ID | @base64d')
export AWS_SECRET_ACCESS_KEY=$(oc get secret -n noobaa noobaa-admin -ojson | jq -r '.data.AWS_SECRET_ACCESS_KEY | @base64d')
export AWS_ENDPOINT_URL=$(oc get noobaas noobaa -ojson | jq -r '.status.services["serviceS3"].externalDNS[0]')

aws s3 --endpoint-url "${AWS_ENDPOINT_URL}" ls
```

- Upgrading Noobaa: <https://github.com/noobaa/noobaa-operator/issues/171#issuecomment-847759757>
