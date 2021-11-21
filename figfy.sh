#!/bin/bash 

# prepopulate figure shortcodes for all images in current working directory
# append output to a file that is optionally named as the first argument
# or to a file called 'scratch.md'
# the content is also stored in the system clipboard

outfile="scratch.md"
[ ! -z "${1}" ] && outfile="${1}" 
touch $outfile
find ./ -type f \( -iname \*.jpg -o -iname \*.png \) -print0 | while read -d $'\0' file
do
    filename="${file##*/}"
    basename="${filename%.*}"
    printf $'{{%% mefig "%s" /%%}}\n' $basename | tee --append "${outfile}" | xsel --append --clipboard 
done

