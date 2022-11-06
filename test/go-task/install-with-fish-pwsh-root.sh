#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "fish completion" cat "/root/.config/fish/completions/task.fish"
check "pwsh completion" cat "/root/.local/share/powershell/Scripts/task.ps1"
check "pwsh profile" cat "/root/.config/powershell/Microsoft.PowerShell_profile.ps1" | grep "task.ps1"

# Report result
reportResults
