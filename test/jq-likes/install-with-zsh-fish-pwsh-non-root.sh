#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "ensure i am user vscode"  bash -c "whoami | grep 'vscode'"
check "yq zsh completion" cat /usr/local/share/zsh/site-functions/_yq
check "yq fish completion" cat ~/.config/fish/completions/yq.fish
check "yq pwsh completion" cat ~/.local/share/powershell/Scripts/yq.ps1
check "yq pwsh profile" cat ~/.config/powershell/Microsoft.PowerShell_profile.ps1 | grep "yq.ps1"
check "gojq zsh completion" cat /usr/local/share/zsh/site-functions/_gojq

# Report result
reportResults
