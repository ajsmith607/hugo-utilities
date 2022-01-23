#!/bin/bash

# in the current directory, simultaneously open a metadata file for editing
# alongside a preview of the corresponding image
# quitting vi continues the loop through the files 

function editmetadata {
    mdfile=${1%.*}.md
    currwinid=$2
    vimiv "${1}" & 
    vimivid=$! # process id of fim background process
    # return focus to first window after fim is launched so we can use vi
    # both xdotool commands seem to be needed, 
    # both before and after killing the background process
    xdotool windowactivate --sync "$currwinid"
    xdotool windowfocus --sync "$currwinid"
    vi "${mdfile}" - +":2"
    kill $vimivid
    xdotool windowactivate --sync "$currwinid"
    xdotool windowfocus --sync "$currwinid"
}
export -f editmetadata # now visible to bash subshell 

currwinid=$(xdotool getactivewindow) 
echo "currwinid: ${currwinid}"
find ./ -type f \( -iname \*.jpg -o -iname \*.png \) -print0 -exec bash -c "editmetadata \"{}\" $currwinid" \; 

