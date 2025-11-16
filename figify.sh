#!/usr/bin/env bash

set -eEuo pipefail
IFS=$'\n\t'
trap 'echo "Error on line $LINENO"; exit 1' ERR

# includes run_on_images function
source common.sh

# prepopulate figure shortcodes for all images in current working directory
# append to a file called '.figifytmp' and add to the system clipboard

outfile=".figifytmp"
touch "$outfile"

figify_file() {
    local file="$1"
    local basepath="${file%.*}"
    printf '{{%% fig "%s" "500" /%%}}\n' "$basepath" | tee --append "$outfile" | xsel --clipboard > /dev/null
}

# pass all args directly to run_on_images
run_on_images figify_file "${@:-.}"

echo "Figure shortcodes have been appended to ${outfile} and copied to the clipboard."









