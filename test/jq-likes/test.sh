#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "version" jq --version

# Report result
reportResults
