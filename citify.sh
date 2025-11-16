#!/usr/bin/env bash

set -eEuo pipefail
IFS=$'\n\t'
trap 'echo "Error on line $LINENO"; exit 1' ERR

source common.sh

# for each metadata file, pre-populate initial metadata based on filename convention
# metadata is prepended to any existing file content
# a file in the same folder with the name .init.md will override filenaming conventions after (optional) date
# optional date in format: YYYY-MM-DD

# define additional strings to add to citation metadata
# citesub=""  # replace all citations with this text
# citepre=""  # prepend all citations with this text
# citepost="" # append all citations with this text (leave off last period!ss )

citify_file() {
    
    # if this file already has front matter defined, skip over file to be safe
    # check first line for front matter start string: "---"
    [ $(sed -n '1{/^\-\-\-/p};q' "${file}") ] && { echo "  - ${file} already has metadata defined, skipping."; return; }

    if [[ -n "${citesub}" ]]; then
        # if an init file exists, use it instead
        citetext="${citesub}"
    else
        filename="${file##*/}"
        basename="${filename%.*}"
        dirpath=$(dirname "$file")
       
        date=`date -d "${basename:0:10}" +'%d %b %Y' 2> /dev/null` 
        datevalidity=$? # get date command exit status
        
        # check that we have a valid ISO date
        if [ "${datevalidity}" -eq 0 ]; then
            citetext=${basename:10}
        else
            date=""
            citetext=${basename}
        fi
        # replace dashes with spaces, title case, and append any command line argument
        citetext="${citetext//-/ }"

        # prepend date
        if [ -n "${date}" ]; then
            citetext="${date}, ${citetext}"
        fi 

        # prepend citation 
        if [ -n "${citepre}" ]; then
            citetext="${citepre}${citetext} "  
        fi

        # append citation
        if [ -n "${citepost}" ]; then
            citetext="${citetext}${citepost}"  
        fi
    fi 

    # prepend formatted front matter string to file
    mdcontent="---\ncitation: \"${citetext}.\"\n---\n\n"
    mdcontent+=`cat "${file}"`
    echo -e "$mdcontent" > "$file"
}

# No argument — process all image files
find ./ -type f -iname \*.md -print0 | sort -z | while read -d $'\0' file; do
    citify_file "$file"
done




