#!/bin/bash

# in the current directory, simultaneously open a metadata file for editing
# alongside a preview of the corresponding image
# quitting vi continues the loop through the files 

# if -t is passed, the script will track progress by adding file name
# to text file and checking/skipping these on subsequent runs.
# see https://www.computerhope.com/unix/bash/getopts.htm
TRACK=0                                  
usage() {                                 # Function: Print a help message.
    echo "Usage: $0 [ -t ]" 1>&2 
}
exit_abnormal() {                         # Function: Exit with error.
    usage
    exit 1
}

option_config="t"
while getopts option_config options; do   # Loop: Get the next option;
    case "${options}" in                    # 
        t)                                    # If the option is t,
            TRACK=1
            ;;
        *)                                    # If unknown (any other) option:
            exit_abnormal                       # Exit abnormally.
            ;;
  esac
done

function editmetadata {
    mdfile=${1%.*}.md
    TRACKFILE=edittracking.txt
    TRACK=${3}
    if [[ ${TRACK} -gt 0 ]]; then
        if [ $(grep -q "^${mdfile}"'$' "${TRACKFILE}") ]; then echo "skipping: ${mdfile}"; return; fi
    fi 

    currwinid=${2}
    vimiv "${1}" & 
    vimivid=$! # process id of fim background process
    # return focus to first window after fim is launched so we can use vi
    # both xdotool commands seem to be needed, 
    # both before and after killing the background process
    xdotool windowactivate --sync "$currwinid"
    xdotool windowfocus --sync "$currwinid"
    vi "$mdfile" - +":2"
    kill $vimivid
    xdotool windowactivate --sync "$currwinid"
    xdotool windowfocus --sync "$currwinid"
    if [[ $TRACK -gt 0 ]]; then
        echo "$mdfile" >> $TRACKFILE
    fi 
}
export -f editmetadata # now visible to bash subshell 

currwinid=$(xdotool getactivewindow) 
echo "currwinid: ${currwinid}"
find ./ -type f \( -iname \*.jpg -o -iname \*.png \) -print0 -exec bash -c "editmetadata \"{}\" ${currwinid} ${TRACK}" \; 

exit 0                                    # Exit normally.
