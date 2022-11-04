#!/bin/bash
set -eu

source dev-container-features-test-lib

check "go is available" go version
check "hugo is available" hugo version

reportResults
