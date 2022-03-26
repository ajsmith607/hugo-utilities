#!/bin/bash

function editmetadata {
    basename=`basename ${1} .md`
    fim -wa "$basename".{jpg,png} &
    fimpid=$! # process id of fim background process
    echo "${basename}" 
    echo "fimpid: " $fimpid
    vi ${1} 
    pkill -15 $fimpid
    exit
}
export -f editmetadata 
find ./ -type f -iname \*.md -print0 | xargs -0 -p {
    bash -c 'editmetadata "${0}"' 
#find . -exec bash -c 'dosomething "$1"' _ {} \;

