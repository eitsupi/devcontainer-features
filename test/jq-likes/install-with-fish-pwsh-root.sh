#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "yq fish completion" cat "/root/.config/fish/completions/yq.fish"
check "yq pwsh completion" cat "/root/.local/share/powershell/Scripts/yq.ps1"
check "yq pwsh profile" cat "/root/.config/powershell/Microsoft.PowerShell_profile.ps1" | grep "yq.ps1"

# Report result
reportResults
