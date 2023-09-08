#!/usr/bin/env bash

set -e

LATEST_VERSION="$(git ls-remote --tags https://github.com/jqlang/jq | grep -oP "jq\\-\\K[0-9]+\.[0-9]+$" | sed "s/\([a-zA-Z]\+\)/-\1-/g" | sort -t - -k 1,1Vr -k 2,2 -k 3,3nr | sed "s/-//g" | head -n 1)"

# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "version" bash -c "jq --version | grep -q '$LATEST_VERSION'"

# Report result
reportResults
