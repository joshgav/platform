## OpenShift Clusters

- To shutdown all nodes in a cluster:

```bash
for node in $(oc get nodes -o jsonpath='{.items[*].metadata.name}'); do oc debug node/${node} -- chroot /host shutdown -h 10; done
```