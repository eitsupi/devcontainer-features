#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "ensure i am user vscode" bash -c "whoami | grep 'vscode'"
check "bd version is 0.45.0" bash -c "bd version | grep '0.45.0'"
check "bash completion" bash -c "cat ~/.bashrc_profile | grep bd"
check "fish completion" bash -c "cat ~/.config/fish/completions/bd.fish | grep bd"

reportResults
