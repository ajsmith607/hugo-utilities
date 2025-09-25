#!/bin/bash

FILESIZE="${1:-5M}"    # default 5M
BATCHSIZE="${2:-5}"    # default 5

# Find files over threshold, sorted by size ascending
mapfile -t FILES < <(
    find . -type f \( -iname '*.jpg' -o -iname '*.png' \) -size +"$FILESIZE" \
        -printf '%s\t%p\n' \
    | sort -n \
    | cut -f2
)

COUNT=${#FILES[@]}
echo "There are $COUNT files over $FILESIZE."

if (( COUNT > 0 )); then
    echo "Processing in batches of $BATCHSIZE."
    for ((i=0; i<COUNT; i+=BATCHSIZE)); do
        batch=( "${FILES[@]:i:BATCHSIZE}" )
        echo "Opening batch: ${batch[*]}"
        gimp "${batch[@]}"
        echo "Closed batch $((i/BATCHSIZE+1))."
    done
fi
