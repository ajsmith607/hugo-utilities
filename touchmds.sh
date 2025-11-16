#!/usr/bin/env bash

set -eEuo pipefail
IFS=$'\n\t'
trap 'echo "Error on line $LINENO"; exit 1' ERR

# includes run_on_images function
source common.sh

# create any missing metadata files alongside images
touch_file() {
    local file="$1"
    local basepath="${file%.*}"
    local mdfile="${basepath}.md"
    [ -f "${mdfile}" ] || { touch "${mdfile}" ; } 
}

# pass all args directly to run_on_images
run_on_images touch_file "${@:-.}"


