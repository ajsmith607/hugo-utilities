#!/bin/bash 

# create any missing metadata files alongside image$s
find ./ -type f \( -iname \*.jpg -o -iname \*.png \) -print0 | while read -d $'\0' file
do
    dirname="${file%/*}"
    filenameonly="${file##*/}"
    basename="${filenameonly%.*}"
    [ -f "$mdfile" ] || { touch "$mdfile" ; echo "${mdfile} created" ; } 
done 

