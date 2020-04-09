#!/usr/bin/env bash

source ./vars.sh

helm upgrade --install --namespace "${NAMESPACE}" \
  "${RELEASE_NAME}" \
  "${CHART}" \
  -f values.yaml \
  "$@"
