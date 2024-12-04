#!/usr/bin/env bash

JQ_VERSION=${JQVERSION:-"latest"}
YQ_VERSION=${YQVERSION:-"none"}
GOJQ_VERSION=${GOJQVERSION:-"none"}
XQ_VERSION=${XQVERSION:-"none"}
JAQ_VERSION=${JAQVERSION:-"none"}

ALLOW_JQ_RC=${ALLOWJQRCVERSION:-"false"}

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
    local suffix=${6:-""}
    if [ "$(echo "${requested_version}" | grep -o "." | wc -l)" != "2" ]; then
        local escaped_separator=${separator//./\\.}
        local last_part
        if [ "${last_part_optional}" = "true" ]; then
            last_part="(${escaped_separator}[0-9]+)*?"
        else
            last_part="${escaped_separator}[0-9]+"
        fi
        local regex="${prefix}\\K[0-9]+${escaped_separator}[0-9]+${last_part}${suffix}$"
        local version_list
        check_git
        check_packages ca-certificates
        version_list="$(git ls-remote --tags "${repository}" | grep -oP "${regex}" | tr -d ' ' | tr "${separator}" "." | sed "s/\([a-zA-Z]\+\)/-\1-/g" | sort -t - -k 1,1Vr -k 2,2 -k 3,3nr | sed "s/-//g")"
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

setup_gojq_completions() {
    local username=$1
    local completions_dir=$2
    local for_zsh=${3:-"true"}

    # zsh
    local zsh_comp_file="${completions_dir}/_gojq"
    if [ "${for_zsh}" = "true" ] && [ -f "${zsh_comp_file}" ] && [ -d /usr/local/share/zsh/site-functions/ ] ; then
        echo "Installing zsh completion..."
        mv "${zsh_comp_file}" /usr/local/share/zsh/site-functions/_gojq
        chown -R "${username}:${username}" /usr/local/share/zsh/site-functions/_gojq
    fi
}

download_old_jq() {
    local version
    local output_file
    local architecture

    version=$1
    output_file=$2
    architecture="$(dpkg --print-architecture)"

    if [ "${architecture}" = "arm64" ]; then
        echo "(!) Architecture $architecture unsupported for jq ${version}"
        exit 1
    fi

    curl -fsL "https://github.com/jqlang/jq/releases/download/jq-${version}/jq-linux64" -o "${output_file}"
}

export DEBIAN_FRONTEND=noninteractive

if [ "${JQ_VERSION}" = "os-provided" ]; then
    echo "Installing jq via OS package manager..."
    check_packages jq
    JQ_VERSION="none"
else
    if [ "${ALLOW_JQ_RC}" = "true" ]; then
        jq_version_suffix="(rc[0-9]+)?"
    else
        jq_version_suffix=""
    fi
    # Soft version matching
    find_version_from_git_tags JQ_VERSION "https://github.com/jqlang/jq" "tags/jq-" "." "true" "${jq_version_suffix}"
fi

# Soft version matching
find_version_from_git_tags YQ_VERSION "https://github.com/mikefarah/yq"
find_version_from_git_tags GOJQ_VERSION "https://github.com/itchyny/gojq"
find_version_from_git_tags XQ_VERSION "https://github.com/MiSawa/xq"
find_version_from_git_tags JAQ_VERSION "https://github.com/01mf02/jaq"

if [ "${JQ_VERSION}" != "none" ]; then
    check_packages curl ca-certificates
    echo "Downloading jq ${JQ_VERSION}..."
    mkdir /tmp/jq
    curl -fsL "https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/jq-linux-${architecture}" -o /tmp/jq/jq ||
        download_old_jq "${JQ_VERSION}" /tmp/jq/jq
    mv /tmp/jq/jq /usr/local/bin/jq
    chmod +x /usr/local/bin/jq
    rm -rf /tmp/jq
fi

if [ "${YQ_VERSION}" != "none" ]; then
    check_packages curl ca-certificates
    echo "Downloading yq ${YQ_VERSION}..."
    mkdir /tmp/yq
    curl -fsL "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${architecture}.tar.gz" | tar xz -C /tmp/yq
    mv "/tmp/yq/yq_linux_${architecture}" /usr/local/bin/yq
    pushd /tmp/yq
    ./install-man-page.sh
    popd
    rm -rf /tmp/yq
    setup_yq_completions "${USERNAME}"
fi

if [ "${GOJQ_VERSION}" != "none" ]; then
    check_packages curl ca-certificates
    echo "Downloading gojq ${GOJQ_VERSION}..."
    mkdir /tmp/gojq
    curl -fsL "https://github.com/itchyny/gojq/releases/download/v${GOJQ_VERSION}/gojq_v${GOJQ_VERSION}_linux_${architecture}.tar.gz" | tar xz -C /tmp/gojq
    mv "/tmp/gojq/gojq_v${GOJQ_VERSION}_linux_${architecture}/gojq" /usr/local/bin/gojq
    setup_gojq_completions "${USERNAME}" "/tmp/gojq/gojq_v${GOJQ_VERSION}_linux_${architecture}"
    rm -rf /tmp/gojq
fi

if [ "${XQ_VERSION}" != "none" ]; then
    check_packages curl ca-certificates
    echo "Downloading xq ${XQ_VERSION}..."
    mkdir /tmp/xq
    curl -fsL "https://github.com/MiSawa/xq/releases/download/v${XQ_VERSION}/xq-v${XQ_VERSION}-$(uname -m)-unknown-linux-musl.tar.gz" | tar xz -C /tmp/xq
    mv "/tmp/xq/xq-v${XQ_VERSION}-$(uname -m)-unknown-linux-musl/xq" /usr/local/bin/xq
    rm -rf /tmp/xq
fi

if [ "${JAQ_VERSION}" != "none" ]; then
    check_packages curl ca-certificates
    echo "Downloading jaq ${JAQ_VERSION}..."
    curl -fsL "https://github.com/01mf02/jaq/releases/download/v${JAQ_VERSION}/jaq-$(uname -m)-unknown-linux-musl" -o /usr/local/bin/jaq ||
        curl -fsL "https://github.com/01mf02/jaq/releases/download/v${JAQ_VERSION}/jaq-$(uname -m)-unknown-linux-gnu" -o /usr/local/bin/jaq ||
        curl -fsL "https://github.com/01mf02/jaq/releases/download/v${JAQ_VERSION}/jaq-v${JAQ_VERSION}-$(uname -m)-unknown-linux-musl" -o /usr/local/bin/jaq ||
        curl -fsL "https://github.com/01mf02/jaq/releases/download/v${JAQ_VERSION}/jaq-v${JAQ_VERSION}-$(uname -m)-unknown-linux-gnu" -o /usr/local/bin/jaq
    chmod +x /usr/local/bin/jaq
fi

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
