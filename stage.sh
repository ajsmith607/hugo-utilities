#!/bin/bash

# check for uncomitted changed in a dependent repo
# or override this safety feature
if [ -z "${1}" ]; then
    depRepo="../undergo"
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

compile-assets.sh

# regenerate static site 
# run image processing garbage collection 
# to delete old generated files no longer neeeded
hugo build --cleanDestinationDir --gc --minify 

cd docs 

http-server &

cd ..
