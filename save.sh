#!/bin/bash

if [ -z "$1" ]; then
   echo "a commit message is needed and missing"
   exit
fi

# check for uncomitted changed in a dependent repo
# or override this safety feature
if [ -z "$2" ]; then
    depRepo="../hugo-min-components"
    if [ ! `realpath "${depRepo}"` == ${PWD} ]; then
        if [[ `git -C "${depRepo}" status --porcelain --untracked-files=no` ]]; then
            echo "there are uncommitted changes in ${depRepo}:"
            echo `git -C "${depRepo}" status --porcelain --untracked-files=no` 
            echo "output $?"
            exit 
        fi
    fi
fi

# update modules
hugo mod get -u

# regenerate static site 
# run image processing garbage collection 
# to delete old generated files no longer neeeded
hugo --gc

# add new files and
# delete files removed by Hugo garbage collection ( with -A)
git add -A .

# commit and push
git commit -m "$1"

