#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "plugins" ls /usr/local/bin/nu_plugin_* | wc -l | grep 0

# Report result
reportResults
