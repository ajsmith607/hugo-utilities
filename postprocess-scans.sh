#!/bin/bash

# usage: mvtest.sh [outputfile] [padlen]

# post-processes the scan files in the current directory

# Files are scanned and a sequence number is appended to the filename pattern given.
# So, for the pattern: "photo-group-sidea" saved as a tiff, 
# the resulting filname is "photo-group-scan-sidea-1.tiff" . 
# This results in all sidea's being sorted in fileviewers before all sideb's.

# This script will rename the files such that the appended sequence number for the file
# is inserted into the filename in a place that will allow for proper
# filename sorting that will keep related scans together and in the expected order.

# The overall filename pattern is:
# <doctype>-[<subject>]-[<{in|out|a|b}side>]-<sequence number>.<extension>

# Examples or prepend patterns:
# photo-
# photo-people-
# photo-people-sidea-
# diary-1883-outside-
# document-sideb-
# postcard-sideb-

# ./createtestfiles.sh

OUTFILE="rename-scans.sh"
if [ $# -eq 1 ]; then
    OUTFILE=$1
fi

# to be safe, if the file already exists, warn the user
WARN="FILE ${OUTFILE} ALREADY EXISTS. RERUN ONLY AFTER MANUAL DELETION."
[ -f "${OUTFILE}" ] && { echo "$WARN" ; exit 1; }

padlen=4
if [ $# -eq 2 ]; then
    padlen=$2
fi

LINES=""
# process each *.tif, *.tiff, *.jpg, *.jpeg
for f in *.tif *.tiff *.jpg *.jpeg; do  
    if [ -e "$f" ]; then

        filename="${f##*/}"
        basename="${filename%.*}"
        extension="${filename##*.}"
       
        # split the filename into an array based on the - character
        IFS='-' read -ra nameparts <<< "$basename"

        sidedef=${nameparts[${#nameparts[@]}-2]}
        scannumber=${nameparts[${#nameparts[@]}-1]}

        # pad the scannumber
        scannumber=$(printf "%0*d" "$padlen" "$scannumber")

        nameparts[${#nameparts[@]}-1]="${scannumber}"

        if [[ "$sidedef" == *"side"* ]]; then

            # switch the order of the scannumber and sidedef in the array
            nameparts[${#nameparts[@]}-2]="${scannumber}"
            nameparts[${#nameparts[@]}-1]="${sidedef}"

        fi

        # join the nameparts array with the - character to form the new filename
        newfilename=$(IFS='-' ; echo "${nameparts[*]}")
        newfilename="${newfilename}.${extension}"

        LINES="${LINES}mv \"${filename}\" \"${newfilename}\"\\n"
    fi
done && echo -e "#!/bin/bash\n\n${LINES}" > "$OUTFILE"

vi "$OUTFILE"
chmod +x "$OUTFILE"



