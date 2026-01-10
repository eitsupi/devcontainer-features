#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "ensure i am user vscode" bash -c "whoami | grep 'vscode'"
check "configure flag exists" bash -c "test -f /usr/local/share/jujutsu-cli/configure-user-from-git.enabled"

check "set git name" bash -c "git config --global user.name 'Dev Container User'"
check "set git email" bash -c "git config --global user.email 'devcontainer@example.com'"
check "remove jj config" bash -c "rm -rf '$HOME/.config/jj'"

# devcontainer features test does not necessarily execute postStartCommand,
# so we call the installed lifecycle script directly.
check "run poststart identity script" bash -c "/usr/local/share/jujutsu-cli/scripts/poststart.sh"

check "jj user.name" bash -c "jj config list --user | grep -F 'user.name = \"Dev Container User\"'"
check "jj user.email" bash -c "jj config list --user | grep -F 'user.email = \"devcontainer@example.com\"'"

reportResults
