#!/usr/bin/env bash

set -e

TILLER_BIN=${1:-"tiller"}
echo "Using tiller binary: ${TILLER_BIN}"

TILLER_NAMESPACE=${TILLER_NAMESPACE:-"tiller"}

# Even though we'll be running tiller locally, it still needs a namespace
if ! kubectl get namespace "$TILLER_NAMESPACE"; then
  echo "Creating namespace: $TILLER_NAMESPACE"
  kubectl create namespace "$TILLER_NAMESPACE"
fi

export TILLER_NAMESPACE
echo "Starting tiller server"
"$TILLER_BIN" -listen=localhost:44134 -storage=secret -alsologtostderr >/dev/null 2>&1

