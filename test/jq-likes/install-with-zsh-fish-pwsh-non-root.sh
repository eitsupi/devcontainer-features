#!/usr/bin/env bash

set -e

NON_ROOT_USER=""
POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
  if id -u "${CURRENT_USER}" >/dev/null 2>&1; then
    NON_ROOT_USER="${CURRENT_USER}"
    break
  fi
done
if [ "${NON_ROOT_USER}" = "" ]; then
  NON_ROOT_USER=root
fi

# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "yq zsh completion" cat "/usr/local/share/zsh/site-functions/_yq"
check "yq fish completion" cat "/home/${NON_ROOT_USER}/.config/fish/completions/yq.fish"
check "yq pwsh completion" cat "/home/${NON_ROOT_USER}/.local/share/powershell/Scripts/yq.ps1"
check "yq pwsh profile" cat "/home/${NON_ROOT_USER}/.config/powershell/Microsoft.PowerShell_profile.ps1" | grep "yq.ps1"
check "gojq zsh completion" cat "/usr/local/share/zsh/site-functions/_gojq"

# Report result
reportResults
