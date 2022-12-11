#!/usr/bin/env bash

VERSION=${VERSION:-"latest"}
INSTALL_NON_STABLE=${INSTALLNONSTABLE:-"false"}

JSON_URL="https://julialang-s3.julialang.org/bin/versions.json"

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

find_version_from_json() {
    local variable_name=$1
    local json_url=$2
    local allow_sufix=${3:-"false"}
    local requested_version=${!variable_name}
    if [ "${requested_version}" = "none" ]; then return; fi

    local regex="[0-9]+\\.[0-9]+\\.[0-9]+$"
    if [ "${allow_sufix}" = "true" ]; then
        regex="[0-9]+\\.[0-9]+\\.[0-9]+.*"
    fi
    local version_list
    version_list="$(curl -sL "${json_url}" | jq '.[].files[] | select(.arch == "'"$(uname -m)"'" and .triplet == "'"$(uname -m)"'-linux-gnu") | .version' -r | grep -oP "${regex}" | sort -rV)"
    if [ "${requested_version}" = "latest" ] || [ "${requested_version}" = "current" ] || [ "${requested_version}" = "lts" ]; then
        declare -g "${variable_name}"="$(echo "${version_list}" | head -n 1)"
    else
        set +e
        declare -g "${variable_name}"="$(echo "${version_list}" | grep -E -m 1 "^${requested_version//./\\.}([\\.\\s]|$)")"
        set -e
    fi

    if [ -z "${!variable_name}" ] || ! echo "${version_list}" | grep "^${!variable_name//./\\.}$" >/dev/null 2>&1; then
        echo -e "Invalid ${variable_name} value: ${requested_version}\nValid values:\n${version_list}" >&2
        exit 1
    fi
    echo "${variable_name}=${!variable_name}"
}

export DEBIAN_FRONTEND=noninteractive

check_packages curl ca-certificates jq

# Soft version matching
find_version_from_json VERSION "${JSON_URL}" "${INSTALL_NON_STABLE}"

echo "Downloading Julia..."
mkdir /opt/julia
curl -sL "$(curl -sL "${JSON_URL}" | jq '."'"${VERSION}"'".files[] | select(.triplet == "'"$(uname -m)"'-linux-gnu") | .url' -r)" | tar xz -C /opt/julia --strip-components 1
ln -s /opt/julia/bin/julia /usr/local/bin/julia

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
