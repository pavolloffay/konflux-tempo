# konflux-tempo

This repository contains Konflux configuration to build Red Hat OpenShift distributed tracing platform (Tempo).

## Build locally

```bash
docker login brew.registry.redhat.io -u
docker login registry.redhat.io -u

podman build -t docker.io/user/tempo-operator:$(date +%s) -f Dockerfile.operator
```

## Release

Open PR `Release - update bundle version` and update [patch_csv.yaml](./bundle-patch/patch_csv.yaml) by submitting a PR with follow-up changes:
1. `spec.version` with the current version e.g. `tempo-operator.v0.13.0-100`
1. `spec.name` with the current version e.g. `tempo-operator.v0.13.0-100`
1. `spec.replaces` with [the previous shipped version](https://catalog.redhat.com/software/containers/rhosdt/opentelemetry-operator-bundle/615618406feffc5384e84400) of CSV e.g. `tempo-operator.v0.13.0-1`
1. `metadata.extra_annotations.olm.skipRange` with the version being productized e.g. `'>=0.6.0 <0.13.0-100'`

Once the PR is merged and bundle is built. Open another PR `Release - update catalog` with:
* Updated [catalog template](./catalog/catalog-template.json) with the new bundle (get the bundle pullspec from [Konflux](https://console.redhat.com/application-pipeline/workspaces/rhosdt/applications/otel/components/tempo-bundle)):
   ```bash
   opm alpha render-template basic catalog/catalog-template.json > catalog/tempo-product/catalog.json && \
   opm validate catalog/tempo-product/ 
   ```

(TODO verify) After konflux builds the bundle create one more PR to change the registry to `registry.redhat.io` see https://konflux-ci.dev/docs/advanced-how-tos/releasing/maintaining-references-before-release/
