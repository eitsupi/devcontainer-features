#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "pwsh profile" bash -c "cat /root/.config/powershell/Microsoft.PowerShell_profile.ps1 | grep task"
check "fish completion" bash -c "cat /root/.config/fish/completions/task.fish | grep task"

# Report result
reportResults
