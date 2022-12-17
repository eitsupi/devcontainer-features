#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "version" duckdb --version | grep "0.5.1"

# Report result
reportResults
