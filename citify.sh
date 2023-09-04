#!/bin/bash

# for each metadata file, pre-populate initial metadata based on filename convention
# metadata is prepended to any existing file content
# a file in the same folder with the name .init.md will override filenaming conventions after (optional) date
# optional date in format: YYYY-MM-DD

app=${1}
INIT=".init.txt"

find ./ -type f -iname \*.md -print0 | sort -z | while read -d $'\0' file; do

    # if this file already has front matter defined, skip over file to be safe
    # check first line for front matter start string: "---"
    [ $(sed -n '1{/^\-\-\-/p};q' "${file}") ] && { echo "  - ${file} already has metadata defined, skipping."; continue; }

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
  
    # if an init file exists, use it instead
    INITPATH="${dirpath}/${INIT}"
    if [[ -f "$INITPATH" ]]; then
        citetext=$(cat "$INITPATH")
    fi 

    # prepend date
    if [ -n "${date}" ]; then
        citetext="${date}, ${citetext}"
    fi 

    # append whatever was passed
    if [ -n "${app}" ]; then
        citetext="${citetext} ${app}"  
    fi

    # prepend formatted front matter string to file
    mdcontent="---\ncitation: \"${citetext}.\"\n---\n\n"
    mdcontent+=`cat "${file}"`
    echo -e "$mdcontent" > "$file"

done

# mv "$INIT" .init.bac
