#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "version" bash -c "jq --version | grep -q 'jq-1.5'"

# Report result
reportResults
