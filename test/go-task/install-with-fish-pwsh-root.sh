#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "version" task --version | grep "$LATEST_VERSION"
check "fish completion" cat "/root/.config/fish/completions/task.fish"
check "pwsh completion" cat "/root/.local/share/powershell/Scripts/task.ps1"

# Report result
reportResults
