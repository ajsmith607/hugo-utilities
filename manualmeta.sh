#!/bin/bash

# in the current directory, simultaneously open a metadata file for editing
# alongside a preview of the corresponding image
# quitting vi continues the loop through the files 

function yn {
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;  
            [Nn]*) echo "Aborted" ; return  1 ;;
        esac
    done
}
export -f yn # now visible to bash subshell 

function editmetadata {
    basename=`basename ${1} .md`
    currwinid=$2
    fim -wa "$basename".{jpg,png} & 
    fimpid=$! # process id of fim background process
    # return focus to first window after fim is launched so we can use vi
    # both xdotool commands seem to be needed, 
    # both before and after killing the background process
    xdotool windowactivate --sync $currwinid
    xdotool windowfocus --sync $currwinid
    vi ${1} - +":2"
    kill $fimpid
    xdotool windowactivate --sync $currwinid
    xdotool windowfocus --sync $currwinid
}
export -f editmetadata # now visible to bash subshell 

currwinid=`xdotool getactivewindow`
find ./ -type f -iname \*.md -print0 -exec bash -c "editmetadata \"{}\" $currwinid" \; 

