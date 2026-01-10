#!/usr/bin/env bash

set -e

LATEST_VERSION="$(git ls-remote --tags https://github.com/jj-vcs/jj | grep -oP "v\\K[0-9]+\\.[0-9]+\\.[0-9]+" | sort -V | tail -n 1)"

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "version" bash -c "jj --version | grep \"$LATEST_VERSION\""

if [ -f /home/vscode/.bashrc_profile ]; then
    check "bash completion profile (non-root)" bash -c "test -s /home/vscode/.bashrc_profile"
    check "bash completion file (non-root)" bash -c "test -f /home/vscode/.local/share/bash-completion/completions/jj.bash"
fi
if [ -f /root/.bashrc_profile ]; then
    check "bash completion profile (root)" bash -c "test -s /root/.bashrc_profile"
    check "bash completion file (root)" bash -c "test -f /root/.local/share/bash-completion/completions/jj.bash"
fi

if [ -d /usr/local/share/zsh/site-functions/ ]; then
    check "zsh completion" bash -c "test -f /usr/local/share/zsh/site-functions/_jj"
fi

if [ -d /home/vscode/.config/fish ]; then
    check "fish completion (non-root)" bash -c "test -f /home/vscode/.config/fish/completions/jj.fish"
fi
if [ -d /root/.config/fish ]; then
    check "fish completion (root)" bash -c "test -f /root/.config/fish/completions/jj.fish"
fi

reportResults
