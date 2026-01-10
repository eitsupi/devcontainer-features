#!/usr/bin/env bash

set -e

LATEST_VERSION="$(git ls-remote --tags https://github.com/steveyegge/beads | grep -oP "[0-9]+\\.[0-9]+\\.[0-9]+" | sort -V | tail -n 1)"

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "version" bash -c "bd version | grep $LATEST_VERSION"

if [ -f /home/vscode/.bashrc_profile ]; then
    check "bash completion (non-root)" bash -c "test -s /home/vscode/.bashrc_profile"
fi
if [ -f /root/.bashrc_profile ]; then
    check "bash completion (root)" bash -c "test -s /root/.bashrc_profile"
fi

if [ -d /usr/local/share/zsh/site-functions/ ]; then
    check "zsh completion" bash -c "test -f /usr/local/share/zsh/site-functions/_bd"
fi

if [ -d /home/vscode/.config/fish ]; then
    check "fish completion (non-root)" bash -c "test -f /home/vscode/.config/fish/completions/bd.fish"
fi
if [ -d /root/.config/fish ]; then
    check "fish completion (root)" bash -c "test -f /root/.config/fish/completions/bd.fish"
fi

reportResults
