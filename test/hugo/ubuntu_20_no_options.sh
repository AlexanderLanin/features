#!/bin/bash
set -eu

source dev-container-features-test-lib

check "python is available" python3 --version
check "pip is available" pip3 --version
check "plantuml is available" plantuml -version
check "sphinx-build is available" sphinx-build --version

reportResults
