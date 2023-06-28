#!/bin/bash

FILESIZE=5M
if [[ -n "$1" ]]; then
    FILESIZE="${1}"
fi

BATCHSIZE=5
if [[ -n "$2" ]]; then
    BATCHSIZE="${2}"
fi

# basic filename hygene
# detox -r ./* 

COUNT=$(find ./ -type f \( -iname \*.jpg -o -iname \*.png \) -size +"$FILESIZE"  | wc -l)

echo "There are $COUNT files over $FILESIZE."
echo "Getting $BATCHSIZE largest."

i=0
while ((i < BATCHSIZE )); do
    find ./ -type f \( -iname \*.jpg -o -iname \*.png \) -size +"$FILESIZE" -exec ls -al {} \; | sort -k 5 -n | head -"$BATCHSIZE" | sed 's/ \+/\t/g' | cut -f 9 | xargs gimp
    ((i=i+BATCHSIZE)) 
done



