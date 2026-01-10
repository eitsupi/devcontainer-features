#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "ensure i am user vscode" bash -c "whoami | grep 'vscode'"
check "jj exists" bash -c "command -v jj"

# completion files should NOT exist (none mode)
check "bash completion not installed" bash -c "test ! -f /home/vscode/.local/share/bash-completion/completions/jj.bash"
check "fish completion not installed" bash -c "test ! -f /home/vscode/.config/fish/completions/jj.fish"

if [ -d /usr/local/share/zsh/site-functions/ ]; then
    check "zsh completion not installed" bash -c "test ! -f /usr/local/share/zsh/site-functions/_jj"
fi

reportResults
