#!/usr/bin/env bash

export TILLER_NAMESPACE=${TILLER_NAMESPACE:-"tiller"}
TILLER=${TILLER:-"tiller"}
echo "Using tiller binary '${TILLER}' and namespace '${TILLER_NAMESPACE}'"

${TILLER} -listen=localhost:44134 -storage=secret -alsologtostderr >/dev/null 2>&1

