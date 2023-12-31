#!/bin/bash

# find unused images in Markdown content files
# the script makes extensive use of bash shell parameter expansions
# https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html

# check that we have the expected (2) parameters
if [[ ! $# -eq 2 ]]; then
    echo "usage: ./${0##*/} <path-to-image-dir> <path-to-content-dir>"
    exit 1
fi

IMGDIR="${1}" 
MDDIR="${2}"
OUTFILE="./.unused-images.txt"
CLIPPATHAFTER="images/"

# check that both parameters are valid paths
if [ ! -e "${IMGDIR}" ]; then
    echo "${IMGDIR} doesn't exist."
    exit 1
fi
if [ ! -e "${MDDIR}" ]; then
    echo "${MDDIR} doesn't exist."
    exit 1
fi

# get all image files to search for 
ALLIMGS=()
mapfile -d '' ALLIMGS < <(find "${IMGDIR}" -type f \( -iname "*.jpg" -o -iname "*.png" \) -print0) 

# sort the array
IFS=$'\n' 
ALLIMGS=($(sort <<<"${ALLIMGS[*]}"))
unset IFS

# convert image paths to basenames
# and search content files for it
# if found, remove from array
imglength=${#ALLIMGS[@]}
echo "${imglength} total images."
for (( i=0; i<imglength; i++ )); do
    figpath=${ALLIMGS[$i]}
    # trim unnecessary base paths
    # figpath=${figpath#"${ASSETDIR}"} 
    figpath=${figpath#*"${CLIPPATHAFTER}"}
    # remove extension
    figpath=${figpath%.*}   
    # -q quiet -r recursive
    # exit code 1 if no lines are selected
    echo "figpath: ${figpath}"
    if grep -qr "${figpath}" "${MDDIR}"; then
        unset "ALLIMGS[$i]"
    else
        ALLIMGS[$i]="{{% fig \"${figpath}\" \"500\" /%}}"
    fi
done

imglength=${#ALLIMGS[@]}
echo "${imglength} unused images."
printf "%s\n" "${ALLIMGS[@]}" > ${OUTFILE}  
xsel -ib < ${OUTFILE}

  

