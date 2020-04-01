#!/usr/bin/env bash

set -e

NAMESPACE="tiller"

# Even though we'll be running tiller locally, it still needs a namespace
kubectl get namespace "$NAMESPACE" || kubectl create namespace "$NAMESPACE"
