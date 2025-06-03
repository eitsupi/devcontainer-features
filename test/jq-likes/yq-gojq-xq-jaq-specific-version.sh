#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "version" bash -c 'yq --version | grep "4.24.5"'
check "gojq version" bash -c 'gojq --version | grep "0.12.12"'
check "xq version" bash -c 'xq --version | grep "0.2"'
check "jaq version" bash -c 'jaq --version | grep "1"'

# Report result
reportResults
