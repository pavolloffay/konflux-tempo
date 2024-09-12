#!/usr/bin/env bash

set -e

# The pullspec should be image index, check if all architectures are there with: skopeo inspect --raw docker://$IMG | jq
export TEMPO_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/tempo/tempo-tempo@sha256:1594bbb49ccc4d40c06462f6875c30f122153b2409ff4e96db14f19815a295a1"
# Separate due to merge conflicts
export TEMPO_QUERY_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/tempo/tempo-query@sha256:e2b213f378d5f1119c0c2270a92d0c95504ce28fcb8a62c4efe3c9de583b8fc1"
# Separate due to merge conflicts
export TEMPO_OPERATOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/tempo/tempo-operator@sha256:cf7167a7ecd48b4e02499ed0cde35636496c88cd771d0c7516e4e44e5a4e34cc"
# separate due to merge conflicts
export TEMPO_GATEWAY_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/tempo/tempo-gateway@sha256:6a6344f789b3fafaa8ede94a29f3764324e4f3d16ffbca4b02fc4fd1835a9464"
# separate due to merge conflicts
export TEMPO_OPA_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/tempo/tempo-opa@sha256:474356fe1dbcbda99ebd190b257f5b4ee7f6706349db4b4451be9cef30ba0b5c"


export CSV_FILE=/manifests/tempo-operator.clusterserviceversion.yaml

sed -i -e "s|ghcr.io/grafana/tempo-operator/tempo-operator\:.*|\"${TEMPO_OPERATOR_IMAGE_PULLSPEC}\"|g" \
	"${CSV_FILE}"

sed -i "s#tempo-container-pullspec#$TEMPO_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#tempo-query-container-pullspec#$TEMPO_QUERY_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#tempo-gateway-container-pullspec#$TEMPO_GATEWAY_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#tempo-opa-container-pullspec#$TEMPO_OPA_IMAGE_PULLSPEC#g" patch_csv.yaml

export AMD64_BUILT=$(skopeo inspect --raw docker://${TEMPO_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="amd64")')
export ARM64_BUILT=$(skopeo inspect --raw docker://${TEMPO_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="arm64")')
export PPC64LE_BUILT=$(skopeo inspect --raw docker://${TEMPO_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="ppc64le")')
export S390X_BUILT=$(skopeo inspect --raw docker://${TEMPO_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="s390x")')

export EPOC_TIMESTAMP=$(date +%s)


# time for some direct modifications to the csv
python3 patch_csv.py
python3 patch_annotations.py
