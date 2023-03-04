#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "ensure i am user codespace"  bash -c "whoami | grep 'codespace'"
check "yq zsh completion" cat /usr/local/share/zsh/site-functions/_yq
check "yq fish completion" cat ~/.config/fish/completions/yq.fish
check "gojq zsh completion" cat /usr/local/share/zsh/site-functions/_gojq

# Report result
reportResults
