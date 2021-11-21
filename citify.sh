#!/bin/bash

# for each metadata file, pre-populate initial metadata based on filename convention
# metadata is prepended to any existing file content
# then immediately open metadata file for editing in vi and display the corresponding image
# TODO: pass URL reference on command line
 
find ./ -type f -iname \*.md -print0 | while read -d $'\0' file; do

    # if this file already has front matter defined, skip over file to be safe
    # check first line for front matter start string: "---"
    [ $(sed -n '1{/^\-\-\-/p};q' "${file}") ] && { echo "  - ${file} already has metadata defined, skipping."; continue; }

    dir="${file%/*}"
    filename="${file##*/}"
    basename="${filename%.*}"
   
    mdcontent="---\n"
    citetext="$basename"
    
    dateout=`date -d "${citetext:0:10}" +'%d %b %Y'`
    datestatus=$? # get date command exit status
    # check that we have a valid ISO date
    if [ "$datestatus" -eq 0 ]; then
        mdcontent+=$dateout
        citetext="${basename:10}"
    fi
   
    h# replace dashes with spaces
    mdcontent+="${citetext//-/ }"
    mdcontent+="\n---\n\n"
  
    # prepend formatted front matter string to file
    mdcontent+=`cat "${file}"`
    echo -e $mdcontent > $file

done

