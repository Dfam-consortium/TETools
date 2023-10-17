#!/bin/sh

set -eu

declare -A tests=(
    ["rmblast"]='/opt/rmblast/bin/rmblast -help'
    ["other"]='placeholder'
)
echo "${tests[other]}"
for test in "${!tests[@]}"; do echo "$test - ${tests[$test]}"; done