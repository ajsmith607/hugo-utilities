#!/bin/bash 

# prepopulate figure shortcodes for all images in current working directory
# append to a file called '.figifytmp' and add to the system clipboard

outfile=".figifytmp"
touch $outfile

# -printf "%P\0" strips out relative directory (./) and outputs a null character like -print0 would
find ./ -type f \( -iname \*.jpg -o -iname \*.png \) -printf "%P\0" | while read -d $'\0' file
do
    basepath=${file%.*}
    printf $'{{%% mefig "%s" /%%}}\n' ${basepath} | tee --append "${outfile}" | xsel --clipboard > /dev/null
done

echo "Figure shortcodes have been appended to the ${outfile} file and are in the clipboard."


