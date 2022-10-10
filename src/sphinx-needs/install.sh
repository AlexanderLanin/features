#!/bin/sh
set -eu
{ # tee script to install.log

  echo "Activating feature 'sphinx-needs'..."

  if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
  fi

  # for install log
  mkdir -p /tmp/build-features/sphinx-needs

  # Ensure apt is in non-interactive to avoid prompts
  export DEBIAN_FRONTEND=noninteractive

  apt-get update -y

  detect_python_version() {
    if ! command -v python3; then
      installed_python_version="0"
    else
      installed_python_version=$(python3 -c 'import sys; print(f"{sys.version_info.major}{sys.version_info.minor:02}")')
    fi
  }

  install_python=false
  detect_python_version
  if [ "$installed_python_version" = "0" ]; then
    echo "Python not installed, attempting to install system version..."
    install_python=true
  elif [ "$installed_python_version" -lt "307" ]; then
    echo "The installed python version is too old, attempting to upgrade to system version..."
    install_python=true
  elif python3 -m pip --version 2>&1 | grep -c "pip"; then
    echo "python3 pip not installed, attempting to upgrade to system version..."
    install_python=true
  fi

  if $install_python; then
    echo "Installing latest stable version of python3 + pip3..."
    apt-get -y install --no-install-recommends python3-pip
    echo "Installing latest stable version of python3 + pip3... done"

    detect_python_version
    if [ "$installed_python_version" -lt "307" ]; then
      # This feature is about sphinx-needs, not python, so we don't want to add add complex python logic here.
      # There is a dedicated python feature for that!
      echo "ERROR: The installed python version is too old ($installed_python_version < 306), this script requires python 3.7 or greater."
      echo "ERROR: Please add python 3.7 or greater to your Docker image or use a python feature like https://github.com/devcontainers/features/tree/main/src/python"
      exit 1
    fi

  fi

  if ! type java >/dev/null 2>&1; then
    echo "Installing latest stable version of default-jre..."
    apt-get -y install --no-install-recommends default-jre
    echo "Installing latest stable version of default-jre... done"
  fi

  if ! type wget >/dev/null 2>&1; then
    echo "Installing latest stable version of wget..."
    apt-get -y install --no-install-recommends wget
    echo "Installing latest stable version of wget... done"
  fi

  if ! type plantuml >/dev/null 2>&1; then
    echo "Installing latest version of plantuml..."

    wget -c https://netcologne.dl.sourceforge.net/project/plantuml/plantuml.jar -O /tmp/plantuml.jar &&
      mkdir -p /usr/share/plantuml &&
      mv /tmp/plantuml.jar /usr/share/plantuml/plantuml.jar

    cat >/usr/local/bin/plantuml <<EOF
#!/bin/sh -eu
java -jar /usr/share/plantuml/plantuml.jar "$@"
EOF

    chmod +x /usr/local/bin/plantuml

    echo "Installing latest version of plantuml... done"
  fi

  if [ -n "${VERSION+x}" ] && [ "$VERSION" = "pre-release" ]; then
    echo "Installing latest development version of sphinx-needs..."
    python3 -m pip install --upgrade --no-cache-dir git+https://github.com/useblocks/sphinx-needs
  elif [ -n "${VERSION+x}" ]; then
    echo "Installing version ${VERSION} of sphinx-needs..."
    python3 -m pip install --upgrade --no-cache-dir "git+https://github.com/useblocks/sphinx-needs@$VERSION"
  else
    echo "Installing latest stable version of sphinx-needs..."
    python3 --version
    python3 -m pip --version
    python3 -m pip install --upgrade --no-cache-dir sphinx-needs
  fi
  echo "Installing sphinx-needs... done"

} 2>&1 | tee /tmp/build-features/sphinx-needs/install.log
