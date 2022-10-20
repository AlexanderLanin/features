#!/bin/sh
set -eu
ls -al
pwd

. ./common.sh

echo "Activating feature 'sphinx-needs'..."

has_python_and_pip "307" || {
  echo "Installing latest system version of python3 + pip3..."
  download_and_run_script https://raw.githubusercontent.com/devcontainers/features/v0.0.4/src/python/install.sh

  has_python_and_pip "307" || {
    # This feature is about sphinx-needs, not python, so we don't want to add add complex python logic here.
    # It will be resolved via https://github.com/devcontainers/features/issues/220 and https://github.com/devcontainers/spec/issues/109
    echo "ERROR: The installed python version is too old, this script requires python 3.7 or greater."
    echo "ERROR: Please add python 3.7 or greater to your Docker image or use a python feature like https://github.com/devcontainers/features/tree/main/src/python"
    exit 1
  }

  echo "Installing latest system version of python3 + pip3... done"
}

if ! type plantuml >/dev/null 2>&1; then
  echo "Installing latest version of plantuml..."
  download_and_run_script https://raw.githubusercontent.com/AlexanderLanin/features/main/src/plantuml/install.sh
  echo "Installing latest version of plantuml... done"
fi

# Missing dependency somewhere?
echo "Adding setuptools and wheel..."
python3 -m pip install --upgrade --no-cache-dir --upgrade pip setuptools wheel

if [ -n "${VERSION+x}" ] && [ "$VERSION" = "pre-release" ]; then
  echo "Installing latest development version of sphinx-needs..."
  echo git+https://github.com/useblocks/sphinx-needs >/tmp/build-features/sphinx-needs/requirements.txt
elif [ -n "${VERSION+x}" ]; then
  echo "Installing version ${VERSION} of sphinx-needs..."
  echo "git+https://github.com/useblocks/sphinx-needs@$VERSION" >/tmp/build-features/sphinx-needs/requirements.txt
else
  echo "Installing latest stable version of sphinx-needs..."
  echo "sphinx-needs>=1.0.2" >/tmp/build-features/sphinx-needs/requirements.txt
fi

echo "sphinxcontrib-plantuml" >>/tmp/build-features/sphinx-needs/requirements.txt
echo "${PLUGINS:-}" | tr " " "\n" >>/tmp/build-features/sphinx-needs/requirements.txt

python3 -m pip install --upgrade --no-cache-dir --upgrade -r /tmp/build-features/sphinx-needs/requirements.txt
echo "Installing sphinx-needs... done"
