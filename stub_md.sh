#!/bin/bash 

# create stub metadata for images and pages based on 
# Can specify '_' as first command line argument if applicable.

# load common code
source ./common.sh

# create any missing metadata files alongside image$s
find ./ -type f \( -iname \*.jpg -o -iname \*.png \) -print0 | while read -d $'\0' file
do
    origdir=${file%/*}
    origfilename="${file##*/}"
    origbasename="${origfilename%.*}"
    mdfilename="${origbasename}.md"
    mdfile="${origdir}/${mdfilename}" 
    [ -f "$mdfile" ] || { touch "$mdfile" ; echo "${mdfile} created" ; } 
done 

# update Git working tree
isingitrepo="$(git rev-parse --is-inside-work-tree 2> /dev/null)"
[ "$isingitrepo" == "true" ] && { git add -A . ; echo "\nThe Git repo tree has been updated accordingly.\n"; }
# [ "$isingitrepo" == "true" ] && { echo "\nThe Git repo tree has been updated accordingly.\n"; }

#prepare for recording page level metadata 
declare -A pagedata 
pgcontent="---\n"

# for each metadata file, populate initial data based on filename convention
find ./ -type f -iname \*.md -print0 | while read -d $'\0' file; do

    echo "${file}"
    # if this file already has front matter defined, skip over file to be safe
    # check first line for front matter start string: "---"
    [ $(sed -n '1{/^\-\-\-/p};q' "${file}") ] && { echo "  - ${file} already has metadata defined, skipping."; continue; }

    dir=${file%/*}
    filename="${file##*/}"
    basename="${filename%.*}"
    mdcontent="---\n"
    
    IFS='_' 
    read -a fields <<< "${basename}"
    for i in "${!fields[@]}"; do 
        value="${fields[$i]}"

        # treat 0 as a null value and skip to the next field
        [ "${value}" == "0" ] && continue

        fldspec="${fieldinfo[$i]}"
        IFS='_' 
        read -a fieldparts <<< ${fldspec}
        valnoseps="${value//-/}"; valsize=${#valnoseps}
        label="${fieldparts[0]:=''}"; unitsize="${fieldparts[1]:=${valsize}}"; changes="${fieldparts[2]:=''}";

        # if the field is the wrong size, skip over it (admittedly, very rudimentary) 
        ((unitsize > 1)) && ((valsize%unitsize)) && { echo "  - ${file} : wrong size for ${label}, got value: '${value}', (size: ${valsize}), expected size: ${unitsize} ."; continue; } 
       
        # chunk up multiple values and make indicated changes, concatenate
        IFS='-'
        dashesonly="${value//[^-]}"
        listsize=${#dashesonly}
        label="${label}: "
        ((listsize>0)) && label="${label}\n"
        read -a allvals <<< ${value}
        for valindex in "${!allvals[@]}"; do
            origval="${allvals[${valindex}]}"
            newval="${origval}"
            [[ "${changes}" =~ .*"e".* ]] && newval="${expands[${origval}]}"
            [[ "${changes}" =~ .*"d".* ]] && newval="$(date -d ${origval} +'%Y-%m-%d')"
            ((listsize>0)) && newval="  - ${newval}"
            allvals[${valindex}]="${newval}"
        done
        IFS=$'\n'
        value="${allvals[*]}"
        valstring="${label}${value}\n";
        mdcontent+="${valstring}\n";

        # also include in page data?
        if [[ ${pagelevelfields[*]} =~ "${label}" ]]; then
            if [[ ! "${pgcontent}" =~ $valstring ]]; then
                pgcontent+="${valstring}\n";
           fi
        fi
    done

    mdcontent+="---\n\n"
    # prepend formatted front matter string to file
    mdcontent+=`cat "${file}"`
    echo -e "${mdcontent}" > "${file}"
    # sed -i "1s/^.*$/${mdcontent}---\n\n/" "${file}" ; # this doesn't work on empty files

    # If an appropriate index file is not already in place, create it with optional '_' from command line 
    # Does not overwrite existing files, nor will it add to a file to a directory
    #   where it already exists in the alternate form.
    ifile="${dir}/${1}index.md"
    if ! compgen -G "${dir}/*index.md" > /dev/null; then
        touch "${ifile}"
    fi
 
    pgcontent+="---\n\n"
    # prepend formatted front matter string to file
    pgcontent+=`cat "${ifile}"`
    echo -e "${pgcontent}" > "${ifile}"
 
done

# find all non-hidden directories (ingores .git), mindepth 1 excludes CWD
#find ./ -mindepth 1 -type d -not -path '*/\.*' -print0 | while read -d $'\0' dir 
#do
    dirnameonly=${dir##*/}
    
    # check for index.md or _index.md
    ifile="${dir}/*index.md"
    echo "  ? ${ifile}"
    #if [[ ! -e "${ifile}" ]] ; then
    if ! compgen -G "${ifile}" > /dev/null; then
        echo -e ";" 
    fi
    
#done

pgcontent+="---\n\n"
# prepend formatted front matter string to file
pgcontent+=`cat "${file}"`
echo -e "${mdcontent}" > "${file}"
 
