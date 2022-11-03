#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "plugins" find /usr/local/bin/nu_plugin_* >/dev/null 2>&1 | wc -l | grep 0

# Report result
reportResults
