#!/bin/bash

# Usage is like basic mv command.
# mvimg.sh originalfile destinationfile

# Safely moves files, creating needed directories
# keeping metadata files and Git synchronized as applicable.

origfile="$1"
[ -f "$origfile" ] || { echo "$origfile does not exist, skipping" ; exit 1; }

# if the destination directory doesn't exist, create it
newfile="$2"
destdir=${newfile%/*}
[ -d "$destdir" ] || mkdir -p "$destdir"

# now it is safe to move the file
mv -iv "$origfile" "$newfile"

# if there is an .md file associated with this image, move it alongside the image
origfilenameonly="${1##*/}"
origbasename="${origfilenameonly%.*}"
mdfilenameonly="${origbasename}.md"
origdir=${origfile%/*}
origmdfile="${origdir}/${mdfilenameonly}" 
newmdfile="${destdir}/${mdfilenameonly}"
[ -f "$origmdfile" ] && mv -iv "$origmdfile" "$newmdfile" 

# Rather than creating parallel logic for Git's git-mv function, 
# just use mv above and then update the tree when done.
isingitrepo="$(git rev-parse --is-inside-work-tree 2> /dev/null)"
[ "$isingitrepo" == "true" ] && { git add -A . ; echo "The Git repo tree has been updated accordingly."; }

