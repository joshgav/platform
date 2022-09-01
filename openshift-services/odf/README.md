# OpenShift Data Foundation (ODF)

Deploy with `deploy.sh`.

Create and use a bucket as in `test.sh`.

## Notes

To label nodes to allow ODF to run:

```bash
oc label nodes --all "cluster.ocs.openshift.io/openshift-storage="
```

## Resources

- https://www.redhat.com/sysadmin/finding-block-and-file1
- https://red-hat-storage.github.io/ocs-training/training/index.html
- https://github.com/rook/rook/blob/master/design/ceph/resource-constraints.md
