#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "ensure i am user vscode"  bash -c "whoami | grep 'vscode'"
check "fish completion" cat ~/.config/fish/completions/task.fish
check "pwsh completion" cat ~/.local/share/powershell/Scripts/task.ps1
check "pwsh profile" cat ~/.config/powershell/Microsoft.PowerShell_profile.ps1 | grep "task.ps1"

# Report result
reportResults
