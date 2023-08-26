apiVersion: objectbucket.io/v1alpha1
kind: ObjectBucketClaim
metadata:
  name: ${S3_BUCKET_NAME}-claim
  namespace: openshift-logging
spec:
  bucketName: ${S3_BUCKET_NAME}
  storageClassName: noobaa.noobaa.io