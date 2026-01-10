#!/usr/bin/env bash

JJ_VERSION=${VERSION:-"latest"}
COMPLETION_MODE=${COMPLETIONMODE:-${COMPLETION_MODE:-"dynamic"}}
CONFIGURE_USER_FROM_GIT=${CONFIGUREUSERFROMGIT:-${CONFIGURE_USER_FROM_GIT:-"true"}}

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
elif [ "${USERNAME}" = "none" ] || ! id -u "${USERNAME}" >/dev/null 2>&1; then
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
    local dot_count
    dot_count="$(echo "${requested_version}" | tr -cd '.' | wc -c)"

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

    if [ "${dot_count}" != "2" ]; then
        if [ "${requested_version}" = "latest" ] || [ "${requested_version}" = "current" ] || [ "${requested_version}" = "lts" ]; then
            declare -g "${variable_name}"="$(echo "${version_list}" | head -n 1)"
        else
            set +e
            declare -g "${variable_name}"="$(echo "${version_list}" | grep -E -m 1 "^${requested_version//./\\.}([\\.\\s]|$)")"
            set -e
        fi
    else
        declare -g "${variable_name}"="${requested_version}"
    fi

    if [ -z "${!variable_name}" ] || ! echo "${version_list}" | grep "^${!variable_name//./\\.}$" >/dev/null 2>&1; then
        echo -e "Invalid ${variable_name} value: ${requested_version}\\nValid values:\\n${version_list}" >&2
        exit 1
    fi
    echo "${variable_name}=${!variable_name}"
}

setup_completions() {
    local mode=${1:-"dynamic"}

    if [ "${mode}" = "none" ]; then
        echo "Skipping shell completions (completionMode=none)."
        return 0
    fi

    if [ "${mode}" != "dynamic" ] && [ "${mode}" != "standard" ]; then
        echo "Invalid completionMode value: ${mode} (expected: dynamic|standard|none)" >&2
        exit 1
    fi

    local home_dir="/home/${USERNAME}"
    if [ "${USERNAME}" = "root" ]; then
        home_dir="/root"
    fi

    # bash
    local bash_profile_path="${home_dir}/.bashrc_profile"
    local bash_completion_dir="${home_dir}/.local/share/bash-completion/completions"
    local bash_completion_file="${bash_completion_dir}/jj.bash"

    mkdir -p "${bash_completion_dir}"
    if [ "${mode}" = "dynamic" ]; then
        COMPLETE=bash jj >"${bash_completion_file}"
    else
        jj util completion bash >"${bash_completion_file}"
    fi

    touch "${bash_profile_path}"
    local source_line="[ -f \"${bash_completion_file}\" ] && source \"${bash_completion_file}\""
    if ! grep -Fqx "${source_line}" "${bash_profile_path}"; then
        echo "${source_line}" >>"${bash_profile_path}"
    fi

    chown -R "${USERNAME}:${USERNAME}" "${home_dir}/.local"
    chown "${USERNAME}:${USERNAME}" "${bash_profile_path}"

    # zsh
    if [ -d /usr/local/share/zsh/site-functions/ ]; then
        if [ "${mode}" = "dynamic" ]; then
            echo "Installing zsh dynamic completion by 'COMPLETE=zsh jj'..."
            COMPLETE=zsh jj >"/usr/local/share/zsh/site-functions/_jj"
        else
            echo "Installing zsh standard completion by 'jj util completion zsh'..."
            jj util completion zsh >"/usr/local/share/zsh/site-functions/_jj"
        fi
        chown "${USERNAME}:${USERNAME}" /usr/local/share/zsh/site-functions/_jj
    fi

    # fish
    local fish_config_dir="${home_dir}/.config/fish"
    if [ -d "${fish_config_dir}" ]; then
        if [ "${mode}" = "dynamic" ]; then
            echo "Installing fish dynamic completion by 'COMPLETE=fish jj'..."
        else
            echo "Installing fish standard completion by 'jj util completion fish'..."
        fi
        mkdir -p "${fish_config_dir}/completions"
        if [ "${mode}" = "dynamic" ]; then
            COMPLETE=fish jj >"${fish_config_dir}/completions/jj.fish"
        else
            jj util completion fish >"${fish_config_dir}/completions/jj.fish"
        fi
        chown -R "${USERNAME}:${USERNAME}" "${fish_config_dir}"
    fi
}

export DEBIAN_FRONTEND=noninteractive

# Soft version matching
find_version_from_git_tags JJ_VERSION "https://github.com/jj-vcs/jj"

check_packages curl ca-certificates tar

echo "Downloading jj (Jujutsu)..."
mkdir -p /tmp/jujutsu-cli

asset_arch="x86_64"
if [ "${architecture}" = "arm64" ]; then
    asset_arch="aarch64"
fi

tmp_archive="/tmp/jujutsu-cli/jj-v${JJ_VERSION}-${asset_arch}-unknown-linux-musl.tar.gz"
curl -fsSL --retry 3 --retry-all-errors -o "${tmp_archive}" "https://github.com/jj-vcs/jj/releases/download/v${JJ_VERSION}/jj-v${JJ_VERSION}-${asset_arch}-unknown-linux-musl.tar.gz"
tar xzf "${tmp_archive}" -C /tmp/jujutsu-cli

mv "/tmp/jujutsu-cli/jj" /usr/local/bin/jj
chmod 0755 /usr/local/bin/jj

# Validate the installed binary works (e.g., catches glibc incompatibilities early)
jj --version >/dev/null

# Set lifecycle scripts (postStart)
LIFECYCLE_SCRIPTS_DIR="/usr/local/share/jujutsu-cli/scripts"
if [ -f scripts/poststart.sh ]; then
    mkdir -p "${LIFECYCLE_SCRIPTS_DIR}"
    cp scripts/poststart.sh "${LIFECYCLE_SCRIPTS_DIR}/poststart.sh"
fi

# Feature option flag for the postStart script
mkdir -p /usr/local/share/jujutsu-cli
if [ "${CONFIGURE_USER_FROM_GIT}" = "true" ]; then
    : > /usr/local/share/jujutsu-cli/configure-user-from-git.enabled
else
    rm -f /usr/local/share/jujutsu-cli/configure-user-from-git.enabled
fi

# Setup completions
setup_completions "${COMPLETION_MODE}"

rm -rf /tmp/jujutsu-cli

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
