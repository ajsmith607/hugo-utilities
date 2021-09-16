#!/bin/bash

env HUGO_MODULE_REPLACEMENTS="github.com/ajs17/hugo-min-components -> $HOME/Dropbox/business/code/hugo/hugo-min-components" 

while true
do

    CMD="hugo server -D"
    $CMD &
    PID=$!
    echo "STARTED process $PID"
    
    sleep 60 

    echo "RESTARTING process $PID"
    kill $PID
    while kill -0 $PID
    do
        sleep 1
    done

done
