#!/bin/bash

FILESIZE=7M
if [[ -n "$1" ]]; then
    FILESIZE="${1}"
fi

BATCHSIZE=5
if [[ -n "$2" ]]; then
    BATCHSIZE="${2}"
fi

# basic filename hygene
detox -r ./* 

COUNT=$(find ./ -type f \( -iname \*.jpg -o -iname \*.png \) -size +"$FILESIZE"  | wc -l)

echo "There are $COUNT files over $FILESIZE."
echo "Getting $BATCHSIZE largest."

find ./ -type f \( -iname \*.jpg -o -iname \*.png \) -size +"$FILESIZE" -exec ls -al {} \; | sort -k 5 -n | head -"$BATCHSIZE" | sed 's/ \+/\t/g' | cut -f 9 | xargs gimp




