#!/bin/bash

if [ -z "$1" ]; then
   echo "a commit message is needed and missing"
   exit
fi

# add new files and
# delete files removed by Hugo garbage collection ( with -A)
git add -A .

# commit and push
git commit -m "${1}"

