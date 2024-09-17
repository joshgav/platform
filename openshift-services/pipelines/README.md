## OpenShift Pipelines

### Example

See the [example](./example/) directory for a typical `git-clone` and `buildah build/push` pipeline.

- git-clone task: <https://github.com/tektoncd/catalog/tree/main/task/git-clone/0.9>
    - Red Hat: https://github.com/openshift-pipelines/tektoncd-catalog/tree/p/tasks/task-git-clone
- buildah: <https://github.com/tektoncd/catalog/tree/main/task/buildah/0.8>
    - Red Hat: <https://github.com/openshift-pipelines/tektoncd-catalog/tree/p/tasks/task-buildah/0.4.1>

### Notes

- The `git-clone` task since v0.8 runs as a nonroot user (ID 65532). You need to modify the podTemplate for the PipelineRun so the pod can access the PV. See [pipelinerun.yaml](./pipelinerun.yaml) for an example, and also see <https://github.com/tektoncd/catalog/blob/main/task/git-clone/0.8/README.md>.

### Resources

- Pipelines as Code
    - <https://pipelinesascode.com/>
    - <https://github.com/openshift-pipelines/pipelines-as-code>
    - <https://docs.openshift.com/container-platform/4.11/cicd/pipelines/using-pipelines-as-code.html>

- Tekton
    - <https://tekton.dev/docs/>
    - <https://github.com/tektoncd/catalog>
    - <https://hub.tekton.dev/>

- OpenShift Pipelines
    - <https://github.com/openshift/tektoncd-pipeline-operator>
    - <https://docs.redhat.com/en/documentation/red_hat_openshift_pipelines>