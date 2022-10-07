#!/bin/sh
set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

echo "Activating feature 'sphinx-needs'..."

# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

# Install pip if not yet installed
if ! type pip >/dev/null 2>&1; then
  apt-get update -y
  apt-get -y install --no-install-recommends \
    python3-pip
fi

pip install --upgrade --no-cache-dir \
  sphinx-needs
