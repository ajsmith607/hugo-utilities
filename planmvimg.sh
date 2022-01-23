#!/bin/bash

# Run in current directory to generate a 
# script for batch moving files and 
# associated metadata. 

CMD="mv"
OUTFILE=".mvimgplan.sh"

# to be safe, if the file already exists, warn the user
WARN="FILE ${OUTFILE} ALREADY EXISTS. RERUN ONLY AFTER MANUAL DELETION."
[ -f $OUTFILE ] && { echo "$WARN" ; exit 1; }

# Get all JPG and PNG images, sort alphabetically by name
# and output to a file of commands to be run later.
# Remember that while loop starts a subshell, so OUTPUT is out of scope
# initialize LINES for first use in subshell.
LINES=""
find ./ -type f \( -iname \*.jpg -o -iname \*.png \) -print0 | sort -z | (while read -d $'\0' file
do
    LINES="${LINES}${CMD} \"${file}\" \"${file}\"\\n"
done && echo -e "#!/bin/bash\n\n${LINES}") > "$OUTFILE"

vi "$OUTFILE"

echo "The file has been saved as ${OUTFILE}"
echo "When ready to run, remember to chmod +x ${OUTFILE}"
