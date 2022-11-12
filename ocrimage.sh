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

# remove any end-of-line hyphenations to re-join words
# (loops over file)
sed -i ':a;N;$!ba;s/-\n//g' "$OUTFILE" 

# mark blank paragraph breaks to re-introduce later
sed -i 's/^\s*$/<BREAK>/g' "$OUTFILE"

# replace any remaining unneeded newlines with single space
# (loops over file)
sed -i ':a;N;$!ba;s/\n/ /g' "$OUTFILE"

# add back in paragraph breaks
sed -i 's/<BREAK>/\n\n/g' "$OUTFILE"

# remove all unneeded leading whitespace
sed -i 's/^\s*//g' "$OUTFILE"

FINALOUTPUT=$(cat "$OUTFILE")
# if newlines are an issue, see
# https://stackoverflow.com/questions/7427262/how-to-read-a-file-into-a-variable-in-shell

# cleanup and return text
#rm "$TMPOCRBASENAME".txt   
echo "$FINALOUTPUT"
