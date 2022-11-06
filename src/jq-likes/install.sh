#!/usr/bin/env bash

JQ_VERSION=${JQVERSION:-"os-provided"}
YQ_VERSION=${YQVERSION:-"none"}
GOJQ_VERSION=${GOJQVERSION:-"none"}

USERNAME=${USERNAME:-"automatic"}

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

setup_yq_completions() {
    local username=$1
    local for_bash=${2:-"true"}
    local for_zsh=${3:-"true"}
    local for_fish=${4:-"true"}
    local for_pwsh=${5:-"true"}
    # bash
    if [ "${for_bash}" = "true" ] && [ -d /etc/bash_completion.d/ ]; then
        if yq shell-completion bash >/dev/null 2>&1; then
            echo "Installing bash completion..."
            yq shell-completion bash >/etc/bash_completion.d/yq
        fi
    fi

    # zsh
    if [ "${for_zsh}" = "true" ] && [ -d /usr/local/share/zsh/site-functions/ ]; then
        if yq shell-completion zsh >/dev/null 2>&1; then
            echo "Installing zsh completion..."
            yq shell-completion zsh >/usr/local/share/zsh/site-functions/_yq
            chown -R "${username}:${username}" /usr/local/share/zsh/site-functions/_yq
        fi
    fi

    # fish
    local fish_config_dir="/home/${username}/.config/fish"
    if [ "${username}" = "root" ]; then
        fish_config_dir="/root/.config/fish"
    fi
    if [ "${for_fish}" = "true" ] && [ -d "${fish_config_dir}" ]; then
        if yq shell-completion fish >/dev/null 2>&1; then
            echo "Installing fish completion..."
            yq shell-completion fish >"${fish_config_dir}/completions/yq.fish"
            chown -R "${username}:${username}" "${fish_config_dir}"
        fi
    fi

    # pwsh
    local pwsh_script_dir="/home/${username}/.local/share/powershell/Scripts"
    local pwsh_profile_dir="/home/${username}/.config/powershell"
    if [ "${username}" = "root" ]; then
        pwsh_script_dir="/root/.local/share/powershell/Scripts"
        pwsh_profile_dir="/root/.config/powershell"
    fi
    local pwsh_profile_file="${pwsh_profile_dir}/Microsoft.PowerShell_profile.ps1"
    if [ "${for_pwsh}" = "true" ] && [ -x "$(command -v pwsh)" ]; then
        if yq shell-completion powershell >/dev/null 2>&1; then
            echo "Installing pwsh completion..."
            mkdir -p "${pwsh_script_dir}"
            mkdir -p "${pwsh_profile_dir}"
            yq shell-completion powershell >"${pwsh_script_dir}/yq.ps1"
            echo "Invoke-Expression -Command ${pwsh_script_dir}/yq.ps1" >>"${pwsh_profile_file}"
            chown -R "${username}:${username}" "${pwsh_script_dir}"
            chown -R "${username}:${username}" "${pwsh_profile_dir}"
        fi
    fi
}

export DEBIAN_FRONTEND=noninteractive

if [ "${JQ_VERSION}" = "os-provided" ]; then
    check_packages jq
fi

# Soft version matching
find_version_from_git_tags YQ_VERSION "https://github.com/mikefarah/yq"
find_version_from_git_tags GOJQ_VERSION "https://github.com/itchyny/gojq"

if [ "${YQ_VERSION}" != "none" ]; then
    check_packages curl ca-certificates
    echo "Downloading yq..."
    mkdir /tmp/yq
    curl -sL "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${architecture}.tar.gz" | tar xz -C /tmp/yq
    mv "/tmp/yq/yq_linux_${architecture}" /usr/local/bin/yq
    pushd /tmp/yq
    ./install-man-page.sh
    popd
    rm -rf /tmp/yq
    setup_yq_completions "${USERNAME}"
fi

if [ "${GOJQ_VERSION}" != "none" ]; then
    check_packages curl ca-certificates
    echo "Downloading gojq..."
    mkdir /tmp/gojq
    curl -sL "https://github.com/itchyny/gojq/releases/download/v${GOJQ_VERSION}/gojq_v${GOJQ_VERSION}_linux_${architecture}.tar.gz" | tar xz -C /tmp/gojq
    mv "/tmp/gojq/gojq_v${GOJQ_VERSION}_linux_${architecture}/gojq" /usr/local/bin/gojq
    rm -rf /tmp/gojq
fi

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
