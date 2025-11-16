#!/bin/bash

# this should already be done before this is ever run?
# compile-assets.sh

toggle-draft.sh "content/family-of-edward-hallock-mills/scratch.md" "draft"

# regenerate static site 
# run image processing garbage collection 
# to delete old generated files no longer neeeded
# hugo build --cleanDestinationDir --gc --minify 
hugo build --gc --minify 

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
google-chrome "http://127.0.0.1:8080" > /dev/null 2>&1

# Wait for process to finish
wait $PID1


