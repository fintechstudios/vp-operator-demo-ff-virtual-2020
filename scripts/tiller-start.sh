#!/usr/bin/env bash

set -e

if [[ -n "${1+x}" ]]; then
  TILLER_BIN=${1}
else
  TILLER_BIN=tiller
fi

echo "Using tiller binary: ${TILLER_BIN}"


TILLER_NAMESPACE=${TILLER_NAMESPACE:-"tiller"}

# Even though we'll be running tiller locally, it still needs a namespace
kubectl get namespace "$TILLER_NAMESPACE" || kubectl create namespace "$TILLER_NAMESPACE"

export TILLER_NAMESPACE
${TILLER_BIN} -listen=localhost:44134 -storage=secret -alsologtostderr >/dev/null 2>&1

