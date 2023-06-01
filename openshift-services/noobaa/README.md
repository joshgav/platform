## Noobaa

Noobaa provides ObjectBucketClaim and ObjectBucket resource types.

ObjectBucketClaims are required by QuayRegistry resource type.

## Usage

1. Install or update the `noobaa` CLI by using commands in `[install.sh](./install.sh)`
1. Run `deploy.sh`, which will install the noobaa operator, create a PV-backed BackingStore and override the default BucketClass to use it.
