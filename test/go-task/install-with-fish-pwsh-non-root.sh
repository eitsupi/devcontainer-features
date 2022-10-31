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
check "version" task --version | grep "$LATEST_VERSION"
check "fish completion" cat "/home/${NON_ROOT_USER}/.config/fish/completions/task.fish"
check "pwsh completion" cat "/home/${NON_ROOT_USER}/.local/share/powershell/Scripts/task.ps1"

# Report result
reportResults
