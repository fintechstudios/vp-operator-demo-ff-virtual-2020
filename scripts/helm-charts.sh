#!/usr/bin/env bash

# Copyright 2018 The Kubernetes Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Based on https://github.com/helm/charts/blob/master/test/repo-sync.sh

# log_error prints an error message
log_error() {
  printf '\e[31mERROR: %s\n\e[39m' "$1" >&2
}

# build charts builds all the charts
build_charts() {
  local repo_dir="${1?Specify repo dir}"
  local build_dir=".${repo_dir}"

  echo "Building charts in ${repo_dir} to ${build_dir}"

  rm -rf "$build_dir"

  mkdir -p "$build_dir"
  exit_code=0

  # TODO: think about only building dirs that have changed
  for dir in "$repo_dir"/*; do
    if helm dependency build "$dir"; then
      helm package --destination "$build_dir" "$dir"
    else
      log_error "Problem building dependencies in '$dir'."
      exit_code=1
    fi
  done

  return "$exit_code"
}

case $1 in
build)
  shift
  build_charts "$@"
  ;;
help)
  usage
  ;;
*)
  usage
  exit 1
  ;;
esac
