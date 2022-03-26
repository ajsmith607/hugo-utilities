#!/bin/bash
# run in top level image folder, probably /data_files

if [ -f "$1" ]
then
    BASENAME="${1%.*}"
    echo "BASNAME: $BASENAME"
    DESTDIR="$(dirname "$2")"
    echo "DESTDIR: $DESTDIR"
    ISGITREPO="$(git rev-parse --is-inside-work-tree 2> /dev/null)"
    if [ "$ISGITREPO" == "true" ]
    then
        #git mv $1 $2
        #git mv ../metadata_files/$1 ../../metadata_files/$2
        echo "This is a Git directory."
    else
        echo "NOT GIT"
    fi 
else
    echo "$1 is not a valid file."
fi
