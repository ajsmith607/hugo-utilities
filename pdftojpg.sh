#!/bin/bash 

# create any missing metadata files alongside images
find ./ -type f -iname \*.pdf -printf "%P\0" | while read -d $'\0' file
do 
    echo "Converting PDF to JPG: ${file}"
    basepath=${file%.*}
    outfile="${basepath}-%03d.jpg"
    # convert -units PixelsPerInch -quality 100 -density 300 -antialias "${file}" -scene 1 -resize 1200x "${outfile}"
    convert -units PixelsPerInch -quality 100 -density 300 -antialias "${file}" -scene 1 "${outfile}"
done 

