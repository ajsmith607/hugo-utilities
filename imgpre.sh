#!/bin/bash

CLIP=""
PRIORCLIP=""

while true
do
    CLIP=`xclip -sel clip -o`
    if [ "$CLIP" != "$PRIORCLIP" ]; then
        if [ -f "$CLIP" ]; then
          # kill previously launched feh now running in the background, and relaunch in background
          kill $!  
          feh -B black -d --scale-down --auto-zoom $CLIP &
          PRIORCLIP=$CLIP
        fi
    fi
    sleep 1
done

