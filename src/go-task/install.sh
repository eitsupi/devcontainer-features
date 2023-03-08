#!/usr/bin/env bash

TASK_VERSION=${VERSION:-"latest"}

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
    local completions_dir=$1
    local for_bash=${2:-"true"}
    local for_zsh=${3:-"true"}
    local for_fish=${4:-"true"}
    local for_pwsh=${5:-"true"}

    # bash
    local bash_profile_path="/home/${USERNAME}/.bashrc_profile"
    local bash_comp_file="${completions_dir}/bash/task.bash"
    if [ "$for_bash" = "true" ] && [ -f "$bash_comp_file" ]; then
        if [ "$USERNAME" = "root" ]; then
            bash_profile_path="/root/.bashrc_profile"
        fi
        echo "Installing bash completion..."
        cat "$bash_comp_file" >>"$bash_profile_path"
        chown -R "${USERNAME}:${USERNAME}" "$bash_profile_path"
    fi

    # zsh
    local zsh_comp_file="${completions_dir}/zsh/_task"
    if [ "$for_zsh" = "true" ] && [ -f "$zsh_comp_file" ] && [ -d /usr/local/share/zsh/site-functions/ ] ; then
        echo "Installing zsh completion..."
        mv "$zsh_comp_file" /usr/local/share/zsh/site-functions/_task
        chown -R "${USERNAME}:${USERNAME}" /usr/local/share/zsh/site-functions/_task
    fi

    # fish
    local fish_config_dir="/home/${USERNAME}/.config/fish"
    local fish_comp_file="${completions_dir}/fish/task.fish"
    if [ "$USERNAME" = "root" ]; then
        fish_config_dir="/root/.config/fish"
    fi
    if [ "$for_fish" = "true" ] && [ -f "$fish_comp_file" ] && [ -d "$fish_config_dir" ] ; then
        echo "Installing fish completion..."
        mkdir -p "$fish_config_dir/completions"
        mv "$fish_comp_file" "$fish_config_dir/completions/task.fish"
        chown -R "${USERNAME}:${USERNAME}" "$fish_config_dir"
    fi

    # pwsh
    local pwsh_script_dir="/home/${USERNAME}/.local/share/powershell/Scripts"
    local pwsh_profile_dir="/home/${USERNAME}/.config/powershell"
    local pwsh_comp_file="${completions_dir}/ps/task.ps1"

    if [ "$USERNAME" = "root" ]; then
        pwsh_script_dir="/root/.local/share/powershell/Scripts"
        pwsh_profile_dir="/root/.config/powershell"
    fi

    local pwsh_profile_file="${pwsh_profile_dir}/Microsoft.PowerShell_profile.ps1"

    if [ "$for_pwsh" = "true" ] && [ -f "$pwsh_comp_file" ] && [ -x "$(command -v pwsh)" ]; then
        echo "Installing pwsh completion..."
        mkdir -p "$pwsh_script_dir"
        mkdir -p "$pwsh_profile_dir"
        mv "$pwsh_comp_file" "${pwsh_script_dir}/task.ps1"
        echo "Invoke-Expression -Command ${pwsh_script_dir}/task.ps1" >>"$pwsh_profile_file"
        chown -R "${USERNAME}:${USERNAME}" "${pwsh_script_dir}"
        chown -R "${USERNAME}:${USERNAME}" "${pwsh_profile_dir}"
    fi
}

export DEBIAN_FRONTEND=noninteractive

# Soft version matching
find_version_from_git_tags TASK_VERSION "https://github.com/go-task/task"

check_packages curl ca-certificates
echo "Downloading Task..."
mkdir /tmp/go-task
curl -sL "https://github.com/go-task/task/releases/download/v${TASK_VERSION}/task_linux_${architecture}.tar.gz" | tar xz -C /tmp/go-task
mv "/tmp/go-task/task" /usr/local/bin/task

# Setup completions if needed
setup_completions "/tmp/go-task/completion"

rm -rf /tmp/go-task

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
