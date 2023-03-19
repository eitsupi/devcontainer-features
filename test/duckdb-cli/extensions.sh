#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "httpfs" bash -c "duckdb -c 'load httpfs'"
check "sqlite_scanner" bash -c "duckdb -c 'load sqlite_scanner'"

# Report result
reportResults
