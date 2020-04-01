#!/usr/bin/env bash

set -e

# wraps bazel calls with an optional env variable BAZEL_BIN
# useful when you want to use a launcher like bazelisk
_bazel() {
  ${BAZEL_BIN:-bazel} "$@"
}

usage() {
      printf '
bazel-test-dotenv.sh will run a bazel test target with a given .env file in the test environment.

Usage:
bazel-test-dotenv.sh ENV_FILE ...TEST_ARGS

You can also set a BAZEL_ARGS environment variable to pass args directly to the bazel command.

BAZEL_ARGS="--bazelrc=/some/other/bazelrc" bazel-test-dotenv.sh ENV_FILE ...TEST_ARGS'
}

main() {
  if [[ -z ${1+x} ]]; then
    usage
    exit 1
  fi

  ENV_FILE="$1"
  shift # send all other args to bazel test

  VARS=$(xargs <"$ENV_FILE")

  ENV_VARS=()
  for VAR in $VARS; do
    ENV_VARS+=("--test_env ${VAR}")
  done

  _bazel $BAZEL_ARGS test ${ENV_VARS[*]} "${@}"
}

main "$@"
