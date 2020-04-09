#!/usr/bin/env bash

source ./vars.sh

helm delete ${RELEASE_NAME} --purge
