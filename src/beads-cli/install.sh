#!/usr/bin/env bash

BEADS_VERSION=${VERSION:-"latest"}

USERNAME=${USERNAME:-${_REMOTE_USER:-"automatic"}}

set -e

# Clean up
rm -rf /var/lib/apt/lists/*

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

architecture="$(dpkg --print-architecture)"
if [ "${architecture}" != "amd64" ] && [ "${architecture}" != "arm64" ]; then
    echo "(!) Architecture $architecture unsupported"
    exit 1
fi

# Determine the appropriate non-root user
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u "${CURRENT_USER}" >/dev/null 2>&1; then
            USERNAME=${CURRENT_USER}
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi
elif [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} >/dev/null 2>&1; then
    USERNAME=root
fi

apt_get_update() {
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}

check_git() {
    if [ ! -x "$(command -v git)" ]; then
        check_packages git
    fi
}

find_version_from_git_tags() {
    local variable_name=$1
    local requested_version=${!variable_name}
    if [ "${requested_version}" = "none" ]; then return; fi
    local repository=$2
    local prefix=${3:-"tags/v"}
    local separator=${4:-"."}
    local last_part_optional=${5:-"false"}
    if [ "$(echo "${requested_version}" | grep -o "." | wc -l)" != "2" ]; then
        local escaped_separator=${separator//./\\.}
        local last_part
        if [ "${last_part_optional}" = "true" ]; then
            last_part="(${escaped_separator}[0-9]+)*?"
        else
            last_part="${escaped_separator}[0-9]+"
        fi
        local regex="${prefix}\\K[0-9]+${escaped_separator}[0-9]+${last_part}$"
        local version_list
        check_git
        check_packages ca-certificates
        version_list="$(git ls-remote --tags "${repository}" | grep -oP "${regex}" | tr -d ' ' | tr "${separator}" "." | sort -rV)"
        if [ "${requested_version}" = "latest" ] || [ "${requested_version}" = "current" ] || [ "${requested_version}" = "lts" ]; then
            declare -g "${variable_name}"="$(echo "${version_list}" | head -n 1)"
        else
            set +e
            declare -g "${variable_name}"="$(echo "${version_list}" | grep -E -m 1 "^${requested_version//./\\.}([\\.\\s]|$)")"
            set -e
        fi
    fi
    if [ -z "${!variable_name}" ] || ! echo "${version_list}" | grep "^${!variable_name//./\\.}$" >/dev/null 2>&1; then
        echo -e "Invalid ${variable_name} value: ${requested_version}\nValid values:\n${version_list}" >&2
        exit 1
    fi
    echo "${variable_name}=${!variable_name}"
}

setup_completions() {
    local for_bash=${1:-"true"}
    local for_zsh=${2:-"true"}
    local for_fish=${3:-"true"}

    # bash
    local bash_profile_path="/home/${USERNAME}/.bashrc_profile"
    if [ "$for_bash" = "true" ]; then
        if [ "$USERNAME" = "root" ]; then
            bash_profile_path="/root/.bashrc_profile"
        fi
        touch "$bash_profile_path"
        echo "Installing bash completion by 'bd completion bash'..."
        bd completion bash >>"$bash_profile_path"
        chown -R "${USERNAME}:${USERNAME}" "$bash_profile_path"
    fi

    # zsh
    if [ "$for_zsh" = "true" ] && [ -d /usr/local/share/zsh/site-functions/ ]; then
        if bd completion zsh >/dev/null 2>&1; then
            echo "Installing zsh completion by 'bd completion zsh'..."
            bd completion zsh >"/usr/local/share/zsh/site-functions/_bd"
            chown -R "${USERNAME}:${USERNAME}" /usr/local/share/zsh/site-functions/_bd
        fi
    fi

    # fish
    local fish_config_dir="/home/${USERNAME}/.config/fish"
    if [ "$USERNAME" = "root" ]; then
        fish_config_dir="/root/.config/fish"
    fi
    if [ "$for_fish" = "true" ] && [ -d "$fish_config_dir" ]; then
        if bd completion fish >/dev/null 2>&1; then
            echo "Installing fish completion by 'bd completion fish'..."
            bd completion fish >"$fish_config_dir/completions/bd.fish"
            chown -R "${USERNAME}:${USERNAME}" "$fish_config_dir"
        fi
    fi
}

export DEBIAN_FRONTEND=noninteractive

# Soft version matching
find_version_from_git_tags BEADS_VERSION "https://github.com/steveyegge/beads"

check_packages curl ca-certificates tar

echo "Downloading Beads CLI (bd)..."
mkdir /tmp/beads-cli
curl -sL "https://github.com/steveyegge/beads/releases/download/v${BEADS_VERSION}/beads_${BEADS_VERSION}_linux_${architecture}.tar.gz" | tar xz -C /tmp/beads-cli

mv "/tmp/beads-cli/bd" /usr/local/bin/bd

# Validate the installed binary works (e.g., catches glibc incompatibilities early)
bd version >/dev/null

# Setup completions
setup_completions

rm -rf /tmp/beads-cli

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
