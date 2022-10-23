#!/bin/sh
set -eu

. ./common.sh

echo "Activating feature 'plantuml'..."

if type plantuml >/dev/null 2>&1; then
  exit 0
fi

if [ "$(id -u)" -ne 0 ]; then
  echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

echo "Checking dependencies..."

install=""

type java >/dev/null 2>&1 || install="$install default-jre"
type graphviz >/dev/null 2>&1 || install="$install graphviz"
type wget >/dev/null || type curl >/dev/null || install="$install wget"

if [ -n "$install" ]; then
  echo "Installing latest stable version of ${install}..."
  export DEBIAN_FRONTEND=noninteractive
  apt-get -y update
  apt-get -y install --no-install-recommends ${install}

  # ToDo: clean only once at the end and only if update was executed by this script.
  apt-get -y clean
  rm -rf /var/lib/apt/lists/*
fi

# ToDo: use GitHub API to get latest release and download directly from GitHub
if [ -n "$VERSION" ] || [ "$VERSION" = "latest" ]; then
  echo "Installing latest stable version of PlantUML..."
  download "https://sourceforge.net/projects/plantuml/files/plantuml.jar/download" /usr/local/bin/plantuml.jar
else
  echo "Installing PlantUML version ${VERSION}..."
  download "https://sourceforge.net/projects/plantuml/files/plantuml.${VERSION}.jar/download" /usr/local/bin/plantuml.jar
fi

cat >/usr/local/bin/plantuml <<EOF
#!/bin/sh -eu
java -jar /usr/local/bin/plantuml.jar "$@"
EOF

chmod +x /usr/local/bin/plantuml

echo "Activating feature 'plantuml'... done"
