#!/bin/bash

# for each metadata file, pre-populate initial metadata based on filename convention
# metadata is prepended to any existing file content

app=${1}

find ./ -type f -iname \*.md -print0 | while read -d $'\0' file; do

    # if this file already has front matter defined, skip over file to be safe
    # check first line for front matter start string: "---"
    [ $(sed -n '1{/^\-\-\-/p};q' "${file}") ] && { echo "  - ${file} already has metadata defined, skipping."; continue; }

    filename="${file##*/}"
    basename="${filename%.*}"
   
    citetext="$basename"
    date=`date -d "${citetext:0:10}" +'%d %b %Y' 2> /dev/null` 
    datevalidity=$? # get date command exit status
    # check that we have a valid ISO date
    if [ "${datevalidity}" -eq 0 ]; then
        citetext="${date}, ${citetext:10}"
    fi
   
    # replace dashes with spaces, title case, and append any command line argument
    citetext="${citetext//-/ }"
    citetext=`echo "${citetext}" | sed 's/[^ ]\+/\L\u&/g'`
    citetext="${citetext} $app"  
    
    # prepend formatted front matter string to file
    mdcontent="---\ncitation: \"${citetext}\"\n---\n\n"
    mdcontent+=`cat "${file}"`
    echo -e $mdcontent > $file

done

