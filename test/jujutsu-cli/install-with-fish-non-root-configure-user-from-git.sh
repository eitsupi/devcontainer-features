#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "ensure i am user vscode" bash -c "whoami | grep 'vscode'"
check "configure flag exists" bash -c "test -f /usr/local/share/jujutsu-cli/configure-user-from-git.enabled"

check "git user.name set by postCreate" bash -c "git config --global user.name | grep -F 'Dev Container User'"
check "git user.email set by postCreate" bash -c "git config --global user.email | grep -F 'devcontainer@example.com'"

check "jj user.name" bash -c "jj config list --user | grep -F 'user.name = \"Dev Container User\"'"
check "jj user.email" bash -c "jj config list --user | grep -F 'user.email = \"devcontainer@example.com\"'"

reportResults
