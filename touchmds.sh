#!/bin/bash 

# create any missing metadata files alongside images
touch_file() {
    local file="$1"
    local basepath="${file%.*}"
    local mdfile="${basepath}.md"
    [ -f "${mdfile}" ] || { touch "${mdfile}" ; } 
}

find ./ -type f \( -iname "*.jpg" -o -iname "*.png" \) -printf "%P\0" | sort -z | while read -rd $'\0' file; do
    touch_file "$file"
done

    


