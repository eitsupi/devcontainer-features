#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "ensure i am user vscode" bash -c "whoami | grep 'vscode'"
check "jj exists" bash -c "command -v jj"
check "jj version" bash -c "jj --version | grep '0.37.0'"

check "bash completion profile" bash -c "test -s /home/vscode/.bashrc_profile"
check "bash completion file" bash -c "test -f /home/vscode/.local/share/bash-completion/completions/jj.bash"

if [ -d /usr/local/share/zsh/site-functions/ ]; then
    check "zsh completion" bash -c "test -f /usr/local/share/zsh/site-functions/_jj"
fi

check "fish completion" bash -c "test -f /home/vscode/.config/fish/completions/jj.fish"

reportResults
