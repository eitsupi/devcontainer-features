#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "duckpgq" bash -c "duckdb -c 'load duckpgq'"
check "quack" bash -c "duckdb -c 'load quack'"

# Report result
reportResults
