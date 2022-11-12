#!/bin/bash 


# create any missing metadata files alongside images
find ./ -type f \( -iname \*.jpg -o -iname \*.png \) -printf "%P\0" | while read -d $'\0' file
do
    basepath=${file%.*}
    mdfile="${basepath}.md"
    [ -f "${mdfile}" ] || { touch "${mdfile}" ; } 
done 

