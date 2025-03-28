# OpenShift Data Foundation (ODF)

- Deploy full ODF with `./deploy-odf.sh`
- Deploy just the operator with `./deploy-operator.sh`
- Deploy the operator and Noobaa with `./deploy-noobaa.sh`
- Test creating and using a bucket with `./test.sh` 

## Notes

To force the ODF wizard to run for a new `StorageCluster` instance, append `?useInitializationResource` to the URL, as in:

```
https://console-openshift-console.apps.ipi.aws.joshgav.com/k8s/ns/openshift-storage/operators.coreos.com~v1alpha1~ClusterServiceVersion/odf-operator.v4.16.1-rhodf/odf.openshift.io~v1alpha1~StorageSystem/~new?useInitializationResource
```

To create a new set of MachineSets for OCS/ODF, run `./create-machinesets.sh`.

To label existing nodes to allow ODF to run:

```bash
oc label nodes --all "cluster.ocs.openshift.io/openshift-storage="
```


## Resources

- https://docs.redhat.com/en/documentation/red_hat_openshift_data_foundation/4.16
- https://www.redhat.com/sysadmin/finding-block-and-file1
- https://red-hat-storage.github.io/ocs-training/training/index.html
- https://github.com/rook/rook/blob/master/design/ceph/resource-constraints.md
- https://github.com/red-hat-storage/odf-operator
- https://github.com/red-hat-storage/ocs-operator
