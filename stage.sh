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


# Function to stop both processes
cleanup() {
  echo "Stopping process $PID1"
  kill "$PID1" 
  wait "$PID1"
}

# Set up a trap to catch signals and run the cleanup function
trap cleanup SIGINT SIGTERM

# Start the second process and capture the PID
http-server docs/ &
PID1=$!
echo "Started process with PID $PID1"
google-chrome "http://127.0.0.1:8089" > /dev/null 2>&1

# Wait for process to finish
wait $PID1


