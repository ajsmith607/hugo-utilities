#!/bin/bash
# most current stand alone version
# expects path to image

LC_CTYPE=en_US.utf8   
IFS='%' # preserves whitespace in shell command output (for tesseract)
   
IMAGEFILE=$1
if [ ! -f "$IMAGEFILE" ]; then
  echo "Can't fine image file at: $IMAGEFILE"
  exit;
fi 

TMPOCRBASENAME="ocrtmp"
OUTFILE="${TMPOCRBASENAME}.txt"

# I decided to manipulate the text in a temp file because capturing
# the text in a variable from tesseract lead to unexpected results
# (sometimes no text, when it would be output to the temp file)

tesseract -c page_separator="" "$IMAGEFILE" "$TMPOCRBASENAME" 

ocrfilecleanup.sh "${OUTFILE}"

FINALOUTPUT=$(cat "$OUTFILE")
# if newlines are an issue, see
# https://stackoverflow.com/questions/7427262/how-to-read-a-file-into-a-variable-in-shell

# cleanup and return text
rm "$TMPOCRBASENAME".txt   
echo "$FINALOUTPUT"
