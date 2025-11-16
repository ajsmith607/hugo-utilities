#!/usr/bin/env bash

set -eEuo pipefail
IFS=$'\n\t'
trap 'printf "ERROR on line %s\n" "$LINENO" >&2; exit 1' ERR

# includes run_on_images function
source common.sh

detox_file() {
    detox -r -s default -s uncgi "$1"
}

# pass all args directly to run_on_images
run_on_images detox_file "${@:-.}"
