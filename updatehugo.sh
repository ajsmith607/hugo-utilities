#!/bin/bash

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
hugo --gc --minify 

