#!/bin/bash


FILESIZE=7M
if [[ -n "$1" ]]; then
    FILESIZE="${1}"
fi

BATCHSIZE=10
if [[ -n "$2" ]]; then
    BATCHSIZE="${2}"
fi

echo ""
echo "DIRECTORY SIZES"

# basic filename hygene
# detox -r ./* 
du -sh ./content 
du -sh ./docs

echo ""
echo "------------"
echo ""

COUNT=$(find ./content -type f \( -iname \*.jpg -o -iname \*.png \) -size +"$FILESIZE"  | wc -l)

if [ "$COUNT" -gt 0 ]; then
    echo "There are $COUNT files over $FILESIZE."
    echo "Getting $BATCHSIZE largest."
    find ./content -type f \( -iname \*.jpg -o -iname \*.png \) -size +"$FILESIZE" -exec du -h '{}' + | sort -hr   
    echo ""
    echo "------------"
    echo ""
fi

echo "REPO INFO: "
# echo "$(git merge-base HEAD origin/main)..HEAD" | git pack-objects --revs --thin --stdout --all-progress-implied -q | wc -c | numfmt --to iec 
git count-objects -vH
echo ""
