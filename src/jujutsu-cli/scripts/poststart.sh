#!/usr/bin/env sh
set -eu

# Generated/installed by the jujutsu-cli Dev Container Feature.
# Intended to run as the container user (remoteUser) on postStartCommand.

ENABLED_FILE="/usr/local/share/jujutsu-cli/configure-user-from-git.enabled"

if [ ! -f "${ENABLED_FILE}" ]; then
  exit 0
fi

if ! command -v jj >/dev/null 2>&1; then
  exit 0
fi

# git may not be installed; skip quietly.
if ! command -v git >/dev/null 2>&1; then
  exit 0
fi

# Don't override if user already has jj config.
if [ -e "${HOME}/.config/jj/config.toml" ] || [ -d "${HOME}/.config/jj/conf.d" ]; then
  exit 0
fi

git_name="$(git config --global user.name 2>/dev/null || true)"
git_email="$(git config --global user.email 2>/dev/null || true)"

if [ -z "${git_name}" ] && [ -z "${git_email}" ]; then
  exit 0
fi

mkdir -p "${HOME}/.config/jj"

if [ -n "${git_name}" ]; then
  jj config set --user user.name "${git_name}"
fi
if [ -n "${git_email}" ]; then
  jj config set --user user.email "${git_email}"
fi
