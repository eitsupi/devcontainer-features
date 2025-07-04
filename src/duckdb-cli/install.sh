#!/usr/bin/env bash

CLI_VERSION=${VERSION:-"latest"}
EXTENSIONS=${EXTENSIONS:-""}
COMMUNITY_EXTENSIONS=${COMMUNITYEXTENSIONS:-""}

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

install_extensions() {
    local username=$1
    local is_community=${3:-"false"}
    local extensions
    local sql_suffix
    IFS=',' read -r -a extensions <<<"$2"

    if [ "${is_community}" = "true" ]; then
        sql_suffix=" from community"
    else
        sql_suffix=""
    fi

    for extension in "${extensions[@]}"; do
        echo "Installing the DuckDB ${extension} extension${sql_suffix}..."
        su "${username}" -c "duckdb -c 'install ${extension}${sql_suffix}'"
        echo "Install ${extension} extension${sql_suffix} successfully!"
    done
}

export DEBIAN_FRONTEND=noninteractive

# Soft version matching
find_version_from_git_tags CLI_VERSION "https://github.com/duckdb/duckdb"

check_packages curl ca-certificates unzip

echo "Downloading DuckDB CLI..."

mkdir /tmp/duckdb-cli
pushd /tmp/duckdb-cli

curl -fL --no-progress-meter "https://github.com/duckdb/duckdb/releases/download/v${CLI_VERSION}/duckdb_cli-linux-$(dpkg --print-architecture).zip" -o duckdb_cli.zip ||
  curl -fL --no-progress-meter "https://github.com/duckdb/duckdb/releases/download/v${CLI_VERSION}/duckdb_cli-linux-$(uname -m).zip" -o duckdb_cli.zip

unzip duckdb_cli.zip
mv duckdb /usr/bin/duckdb

popd
rm -rf /tmp/duckdb-cli

if [ -n "${EXTENSIONS}" ]; then
    install_extensions "${USERNAME}" "${EXTENSIONS}"
fi

if [ -n "${COMMUNITY_EXTENSIONS}" ]; then
    install_extensions "${USERNAME}" "${COMMUNITY_EXTENSIONS}" "true"
fi

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
