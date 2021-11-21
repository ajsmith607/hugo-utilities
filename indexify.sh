#!/bin/bash

# Add missing index.md or _index.md files with sequence number pre-populated.
# If an appropriate index file is not already in place
# Does not overwrite existing files, nor will it add to a file to a directory
#   where it already exists in the alternate form.
# Can specify '_' as first command line argument, the prepend to filename, if applicable.

# find all non-hidden directories (ingores .git), mindepth 1 excludes CWD
find ./ -mindepth 1 -type d -not -path '*/\.*' -print0 | while read -d $'\0' dir 
do

    # check for index.md or _index.md
    ifile="${dir}/*index.md"
    echo "  ? ${ifile}"
    #if [[ ! -e "${ifile}" ]] ; then
    if ! compgen -G "${ifile}" > /dev/null; then
        echo "  NO INDEX"
    else
        echo "  FOUND INDEX"
        head "${ifile}"
    fi
    
done

