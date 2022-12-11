#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "version" nu --version | grep "0.70.0"

# Report result
reportResults
