#!/usr/bin/env bash
export TILLER_NAMESPACE=tiller

if [[ -n "${1+x}" ]]; then
  TILLER_BIN=${1}
else
  TILLER_BIN=tiller
fi

echo "Using tiller binary: ${TILLER_BIN}"

${TILLER_BIN} -listen=localhost:44134 -storage=secret -alsologtostderr >/dev/null 2>&1

