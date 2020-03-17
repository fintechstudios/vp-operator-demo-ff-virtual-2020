#!/usr/bin/env bash

# wraps bazel calls with an optional env variable BAZEL_BIN
# useful when you want to use a launcher like bazelisk
_bazel() {
  ${BAZEL_BIN:-bazel} "$@"
}

# log_error prints an error message
log_error() {
  printf '\e[31mERROR: %s\n\e[39m' "$1" >&2
}

artifact_build() {
  local artifact_dir="${1?Specify artifact directory}"
  local artifact_name
  artifact_name=$(echo "$artifact_dir" | tr "-" _)

  echo "Building artifact '$artifact_name'..."

  # build the pruned jar for deployment
  _bazel build //"${artifact_dir}":"${artifact_name}"_pruned_deploy.jar
}

sync_artifact() {
  local s3_bucket="${1?Specify bucket}"
  local target="${2?Specify the tag}"
  local artifact_dir="${3?Specify artifact directory}"
  local artifact_build_dir="${4:-$artifact_dir}"

  local artifact_name
  artifact_name=$(echo "$artifact_dir" | tr "-" _)

  bazel_gen_dir=$(_bazel info bazel-genfiles)

  echo "Copying artifacts for '$artifact_name' to '$s3_bucket/$artifact_name' for tag '$target' from '$artifact_build_dir'"

  exit_code=0
  echo "copying $target"
  if ! aws s3 cp "${bazel_gen_dir}/${artifact_build_dir}/${artifact_name}_pruned_deploy.jar" "s3://${s3_bucket}/${artifact_dir}/${target}.jar" --follow-symlinks; then
    log_error "Problem copying artifact '$artifact_name' to '$s3_bucket/$artifact_name' for tag '$target'..."
    exit_code=1
  fi

  return "$exit_code"
}

usage() {
  printf "USAGE: artifact-sync.sh COMMAND [...ARGS]
    Build and sync artifacts to S3. The 'bazel' binary can be overriden with the BAZEL_BIN env variable.

    Commands:

      help                                                                     print this usage text
      build ARTIFACT_DIR                                                       build the artifact in a given dir.
      sync S3_BUCKET TAG ARTIFACT_DIR [ARTIFACT_BUILD_DIR=ARTIFACT_DIR]        sync the directoy to S3 under the filename {TAG}.jar
    \n"
}

case $1 in
build)
  shift
  artifact_build "$@"
  ;;
sync)
  shift
  sync_artifact "$@"
  ;;
help)
  usage
  ;;
*)
  usage
  exit 1
  ;;
esac
