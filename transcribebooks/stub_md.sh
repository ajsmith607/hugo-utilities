#!/bin/bash 

# create stub metadata for images and pages based on 

# fieldinfo format:
#   label_size_changes
#
# where:
#   size: the size of each value in the field
#   changes: indicates how to transform the value:
#       e: expand the value
#       q: quote the value
#       d: datify the value according to the date pattern defined above

fieldinfo=(
    seq_0
    copyNum_0
    pageNum_0
    documentPart_2_e
    pageArea_2_e
    flags_0_e
    dates_8_d
    )

pagelevelfields=(seq, pageNum, dates)

declare -A expands 
expands[p]="is photograph"
expands[s]="is scanned"
expands[n]="no edges visible"
expands[t]="top edge visible"
expands[b]="bottom edge visible"
expands[l]="left edge visible"
expands[r]="right edge visible"
expands[f]="visible fold, crease"
expands[w]="is two page spread"
expands[c]="is closeup"
expands[pg]="interior page"
expands[aa]="front cover"
expands[ab]="inside front cover"
expands[zy]="inside back cover"
expands[zz]="back cover"
expands[tp]="title page"
expands[tc]="table of contents"
expands[dc]="dedication"
expands[cc]="all content is visible in the image" 
expands[q1]="first quadrant" 
expands[q2]="second quadrant"
expands[q3]="third quadrant"
expands[q4]="fourth quadrant"

#prepare for recording page level metadata 
declare -A pagedata 
#pgcontent="---\n"

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
        #if [[ ${pagelevelfields[*]} =~ "${label}" ]]; then
        #    if [[ ! "${pgcontent}" =~ $valstring ]]; then
        #        pgcontent+="${valstring}\n";
        #   fi
        #fi
    done

    mdcontent+="---\n\n"
    # prepend formatted front matter string to file
    mdcontent+=`cat "${file}"`
    echo -e "${mdcontent}" > "${file}"
    # sed -i "1s/^.*$/${mdcontent}---\n\n/" "${file}" ; # this doesn't work on empty files

done

# pgcontent+="---\n\n"
# prepend formatted front matter string to file
# pgcontent+=`cat "${file}"`
# echo -e "${pgcontent}" > "${file}"
 
