## Noobaa

Noobaa provides ObjectBucketClaim and ObjectBucket resource types.

It also provides an S3 API to consumers.

## Usage

1. Install `noobaa` CLI with `install-cli.sh`.
1. Run `deploy.sh`. It does the following:
    - installs the noobaa operator
    - configures the default `noobaa` resource
    - creates a 1TB PVC-backed BackingStore as the default backing store
    - creates a default bucket class

Upgrade to the latest images using the `upgrade.sh` script.

## Tips

Access Noobaa buckets via its S3 API as follows:

```bash
export AWS_ACCESS_KEY_ID=$(oc get secret -n noobaa noobaa-admin -ojson | jq -r '.data.AWS_ACCESS_KEY_ID | @base64d')
export AWS_SECRET_ACCESS_KEY=$(oc get secret -n noobaa noobaa-admin -ojson | jq -r '.data.AWS_SECRET_ACCESS_KEY | @base64d')
export AWS_ENDPOINT_URL=$(oc get noobaas noobaa -n noobaa -ojson | jq -r '.status.services["serviceS3"].externalDNS[0]')

aws s3 --endpoint-url "${AWS_ENDPOINT_URL}" ls
```

