#!/usr/bin/env bash

set -e

# The pullspec should be image index, check if all architectures are there with: skopeo inspect --raw docker://$IMG | jq
export TEMPO_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/tempo/tempo@sha256:71ee5dda66553704a9fcbda6b98ce4a8fc601733e4e810cf95cf2f3398d75776"
# Separate due to merge conflicts
export TEMPO_QUERY_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/tempo/tempo-query@sha256:f3f4fad394814c34cea2aec5ae66ad8ffab72ce4bde941af90492e64e012565e"
# separate due to merge conflicts
export TEMPO_GATEWAY_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/tempo/tempo-gateway@sha256:3e5c1425582e7f69c5e928b1cf5bbe539289b52c20fbdd335890aed6b9e075a4"
# separate due to merge conflicts
export TEMPO_OPA_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/tempo/tempo-opa@sha256:035f3c5430f6669e7ba31307fbc6889f8b29655b74f512e91feafa450903c635"
# Separate due to merge conflicts
export TEMPO_OPERATOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/tempo/tempo-operator@sha256:248cc412f5fb53c20f17d8a83ce3093a631d7898531773c68a91aeb5fbbea9db"
# Separate due to merge conflicts
# TODO, we used to set the proxy image per OCP version
export OSE_KUBE_RBAC_PROXY_PULLSPEC="registry.redhat.io/openshift4/ose-kube-rbac-proxy@sha256:8204d45506297578c8e41bcc61135da0c7ca244ccbd1b39070684dfeb4c2f26c"
export OSE_OAUTH_PROXY_PULLSPEC="registry.redhat.io/openshift4/ose-oauth-proxy@sha256:4f8d66597feeb32bb18699326029f9a71a5aca4a57679d636b876377c2e95695"

if [[ $REGISTRY == "registry.redhat.io" ||  $REGISTRY == "registry.stage.redhat.io" ]]; then
  TEMPO_IMAGE_PULLSPEC="$REGISTRY/rhosdt/tempo-rhel8@${TEMPO_IMAGE_PULLSPEC:(-71)}"
  TEMPO_QUERY_IMAGE_PULLSPEC="$REGISTRY/rhosdt/tempo-query-rhel8@${TEMPO_QUERY_IMAGE_PULLSPEC:(-71)}"
  TEMPO_GATEWAY_IMAGE_PULLSPEC="$REGISTRY/rhosdt/tempo-gateway-rhel8@${TEMPO_GATEWAY_IMAGE_PULLSPEC:(-71)}"
  TEMPO_OPA_IMAGE_PULLSPEC="$REGISTRY/rhosdt/tempo-opa-rhel8@${TEMPO_OPA_IMAGE_PULLSPEC:(-71)}"
  TEMPO_OPERATOR_IMAGE_PULLSPEC="$REGISTRY/rhosdt/tempo-rhel8-operator@${TEMPO_OPERATOR_IMAGE_PULLSPEC:(-71)}"
fi


export CSV_FILE=/manifests/tempo-operator.clusterserviceversion.yaml

sed -i "s#tempo-container-pullspec#$TEMPO_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#tempo-query-container-pullspec#$TEMPO_QUERY_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#tempo-gateway-container-pullspec#$TEMPO_GATEWAY_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#tempo-opa-container-pullspec#$TEMPO_OPA_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#tempo-operator-container-pullspec#$TEMPO_OPERATOR_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#ose-kube-rbac-proxy-container-pullspec#$OSE_KUBE_RBAC_PROXY_PULLSPEC#g" patch_csv.yaml
sed -i "s#ose-oauth-proxy-container-pullspec#$OSE_OAUTH_PROXY_PULLSPEC#g" patch_csv.yaml

#export AMD64_BUILT=$(skopeo inspect --raw docker://${TEMPO_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="amd64")')
#export ARM64_BUILT=$(skopeo inspect --raw docker://${TEMPO_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="arm64")')
#export PPC64LE_BUILT=$(skopeo inspect --raw docker://${TEMPO_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="ppc64le")')
#export S390X_BUILT=$(skopeo inspect --raw docker://${TEMPO_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="s390x")')
export AMD64_BUILT=true
export ARM64_BUILT=true
export PPC64LE_BUILT=true
export S390X_BUILT=true

export EPOC_TIMESTAMP=$(date +%s)


# time for some direct modifications to the csv
python3 patch_csv.py
python3 patch_annotations.py
