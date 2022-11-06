#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "version" yq --version | grep "4.24.5"
check "gojq version" gojq --version | grep "0.7.0"

# Report result
reportResults
