#!/bin/bash

# prepopulate figure shortcodes for all images in current working directory
# append to a file called '.figifytmp' and add to the system clipboard

outfile=".figifytmp"
touch "$outfile"

figify_file() {
    local file="$1"
    local basepath="${file%.*}"
    printf '{{%% fig "%s" "500" /%%}}\n' "$basepath" | tee --append "$outfile" | xsel --clipboard > /dev/null
}

if [[ -n "$1" ]]; then
    # Single file argument
    file="$1"
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        exit 1
    fi

    figify_file "$file"
else
    # No argument — process all image files
    find ./ -type f \( -iname "*.jpg" -o -iname "*.png" \) -printf "%P\0" | sort -z | while read -rd $'\0' file; do
        figify_file "$file"
    done
fi

echo "Figure shortcodes have been appended to ${outfile} and copied to the clipboard."









