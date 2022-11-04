#!/bin/sh
set -eu

. ./common.sh

echo "Activating feature 'hugo'..."

# Checking go separately because it may be installed manually and not via apt.
if ! type go >/dev/null 2>&1; then
  apt_install golang
fi

apt_install ca-certificates openssl curl

# Fetch the latest version of Hugo
if [ "$VERSION" = "latest" ]; then
  VERSION=$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4)}')
fi

if [ "$EXTENDED" = "true" ]; then
  VARIANT="hugo_extended"
else
  VARIANT="hugo"
fi

echo "Downloading '${VARIANT}_${VERSION}_Linux-64bit'..."

# Download the latest version of Hugo
mkdir -p /tmp/hugo/
download https://github.com/gohugoio/hugo/releases/download/v${VERSION}/${VARIANT}_${VERSION}_Linux-64bit.tar.gz /tmp/hugo/download.tar.gz
tar xf /tmp/hugo/download.tar.gz -C /tmp/hugo/
mv /tmp/hugo/hugo* /usr/bin/hugo
rm -rf /tmp/hugo/

# Change stack size?
# go get github.com/yaegashi/muslstack && muslstack -s 0x800000 /usr/bin/hugo

echo "Activating feature 'hugo'... done"
