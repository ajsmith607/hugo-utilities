#!/bin/bash

CWD=$(pwd)
cwdname=${CWD##*/}

# output the directory name
echo "$cwdname"

# output the number of subdirectories
echo "volumes: $(find "$CWD" -type d | wc -l)"

# output the number of jpg, png, and tiff files
echo "images: $(find "$CWD" -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.tiff \) | wc -l)"

# output the size of the directory contents
echo "size: $(du -sh "$CWD" | cut -f 1)"

# for each subdirectory, output basic stats as CSV data
find "$CWD" -type d | sort | while read -r dir
do
    dirname=${dir##*/}
    IMAGENUM=$(find "$dir" -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.tiff \) | wc -l)
    # get only the size of the directory
    SIZE=$(du -sh "$dir" | cut -f 1)
    echo "$dirname, $IMAGENUM, $SIZE"
done


