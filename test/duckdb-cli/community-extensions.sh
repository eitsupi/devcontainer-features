#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "nanoarrow" bash -c "duckdb -c 'load nanoarrow'"
check "quack" bash -c "duckdb -c 'load quack'"

# Report result
reportResults
