#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "ensure i am root" bash -c "whoami | grep 'root'"
check "jj exists" bash -c "command -v jj"
check "jj version" bash -c "jj --version | grep '0.37.0'"

check "bash completion profile" bash -c "test -s /root/.bashrc_profile"
check "bash completion file" bash -c "test -f /root/.local/share/bash-completion/completions/jj.bash"

if [ -d /usr/local/share/zsh/site-functions/ ]; then
    check "zsh completion" bash -c "test -f /usr/local/share/zsh/site-functions/_jj"
fi

check "fish completion" bash -c "test -f /root/.config/fish/completions/jj.fish"

reportResults
