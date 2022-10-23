#!/bin/sh
set -eu

# This is not meant to be run directly, but rather via the include from feautres!

if [ "$(id -u)" -ne 0 ]; then
  echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

# arg 1: url
# arg 2: where to
download() {
  if command -v wget; then
    wget -q -O $2 $1
  elif command -v curl; then
    curl -sSL -o $2 $1
  else
    # ToDo: update always? clean always?
    apt-get update -y
    apt-get -y install --no-install-recommends wget
    wget -O $2 $1
    apt-get clean -y
    rm -rf /var/lib/apt/lists/*
  fi
}

# arg 1: url to script
download_and_run_script() {
  mkdir -p /tmp/build-features
  download $1 /tmp/build-features/download_and_run_script.sh
  chmod +x /tmp/build-features/download_and_run_script.sh
  /tmp/build-features/download_and_run_script.sh
  rm -rf /tmp/build-features/download_and_run_script.sh
}

# arg1: min version, format is "xyy" for "x.y.z", e.g. "307" for "3.7.0"
# returns true(1) when python is installed and version is greater or equal to min version
has_python_and_pip() {
  command -v python3 >/dev/null 2>&1 || return 0
  command -v python3 -m pip >/dev/null 2>&1 || return 0

  installed_python_version=$(python3 -c 'import sys; print(f"{sys.version_info.major}{sys.version_info.minor:02}")')
  [ "$installed_python_version" -lt "$1" ] || return 0

  return 1
}
