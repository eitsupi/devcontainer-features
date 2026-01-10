#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "bd version" bash -c "bd version"
check "bash completion" bash -c "cat /root/.bashrc_profile | grep bd"
check "fish completion" bash -c "cat /root/.config/fish/completions/bd.fish | grep bd"

reportResults
