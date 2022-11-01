#!/bin/bash
set -eu

source dev-container-features-test-lib

check "hugo is available" hugo --version

reportResults
