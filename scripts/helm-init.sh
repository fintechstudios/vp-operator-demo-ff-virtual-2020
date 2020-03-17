#!/usr/bin/env bash

export HELM_HOST=:44134
helm init --client-only

# Add common dependency repositories
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com
