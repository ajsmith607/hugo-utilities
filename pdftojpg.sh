#!/bin/bash

# usage: ./pdftojpg.sh [file.pdf] [pages]
# all arguments are optional
# pages can be: "1", "1,3,5", "2-4", "1,3-5,7,9-10"
# pages are 0 based!
pages="" # can be any of the following formats: 1 -- 1,3,5 -- 2-4 -- 1,3-5,9-10
# Convert all PDFs as before
# > ./pdftojpg.sh

# Convert all pages of one file
# > ./pdftojpg.sh input.pdf

# Convert specific pages
# > ./pdftojpg.sh input.pdf 1
# > ./pdftojpg.sh input.pdf 1,3,5
# > ./pdftojpg.sh input.pdf 2-4
# > ./pdftojpg.sh input.pdf 1,3-5,9-10

convert_pdf() {
    local file="$1"
    local pages="$2"
    echo "Converting PDF to JPG: ${file}"

    local basepath="${file%.*}"
    local outfile="${basepath}-%03d.jpg"

    if [[ -n "$pages" ]]; then
        echo "  Selected pages: $pages"
        convert -units PixelsPerInch -quality 100 -density 600 -antialias "${file}"[$pages] -scene 1 "${outfile}"
    else
        convert -units PixelsPerInch -quality 100 -density 600 -antialias "${file}" -scene 1 "${outfile}"
    fi
}

if [[ -n "$1" ]]; then
    # Single file provided
    file="$1"
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        exit 1
    fi
    convert_pdf "$file" "$2"
else
    # No arguments — process all PDFs
    find ./ -type f -iname "*.pdf" -printf "%P\0" | while read -rd $'\0' file; do
        convert_pdf "$file"
    done
fi
