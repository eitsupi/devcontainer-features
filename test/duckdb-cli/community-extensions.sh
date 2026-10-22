#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "nanoarrow" bash -c "duckdb -c 'load nanoarrow'"
check "capi_quack" bash -c "duckdb -c 'load capi_quack'"

# Report result
reportResults
