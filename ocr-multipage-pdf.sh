#!/bin/bash

LC_CTYPE=en_US.utf8   
IFS='%' # preserves whitespace in shell command output (for tesseract)

# pass filename of multipage pdf
if [ $# -ne 1 ]; then
    echo "Usage: $0 <pdf_file>"
    exit 1
fi

basepath=${1%.*}
echo "basepath: $basepath"

mkdir "${basepath}"  
cp "${1}" "${basepath}"
cd "${basepath}" || return 

echo "in directory: " "$(pwd)"

outfile="${basepath}-%03d.jpg"
convert -units PixelsPerInch -quality 100 -density 600 -antialias "${1}" -scene 1 "${outfile}"

find ./ -type f \( -iname \*.jpg -o -iname \*.png \) -printf "%P\0" | while read -rd $'\0' file
do
    tesseract -c page_separator="" "$file" - >> "../${basepath}.txt"
done 

cd - || return
echo "returning to directory: " "$(pwd)"
rm -rf "${basepath}"

ocrfilecleanup.sh "${basepath}.txt"

