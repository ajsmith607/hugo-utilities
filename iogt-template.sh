#!/bin/bash 

# prepopulate figure shortcodes for all images in current working directory
# append to a file called '.figifytmp' and add to the system clipboard

outfile=".skeleton-page"
rm $outfile
touch $outfile
# -printf "%P\0" strips out relative directory (./) and outputs a null character like -print0 would
find ./ -type f \( -iname \*.jpg -o -iname \*.png \) -printf "%P\0" | sort -z | while read -rd $'\0' file
do

    filename="${file##*/}"
    basename="${filename%.*}"
    basepath=${file%.*}
   
    date=$(date -d "${basename:0:10}" +'%d %b %Y, a %A' 2> /dev/null) 
    datevalidity=$? # get date command exit status
    
    # check that we have a valid ISO date
    if [ ${datevalidity} -eq 0 ]; then
        printf $'\n## %s \n'  "${date}" >> "${outfile}"
    fi

    printf $'{{%% fig "%s" "800" /%%}}\n' "${basepath}" >> "${outfile}"
done

echo "Figure shortcodes have been appended to the ${outfile} file and are in the clipboard."

vi ${outfile}

