#!/bin/bash
LC_CTYPE=en_US.utf8

IFS='%' # preserves whitespace in shell command output (for tesseract)
   
FULLPATH=$(echo $1 | sed 's:/*$::')
IMAGESDIR=$2
SEQNUM=$3

IMAGE=$FULLPATH/$IMAGESDIR/$SEQNUM.jpg 
OUTFILE=$FULLPATH/$SEQNUM

TMPFILE=$OUTFILE.txt
MDFILE=$OUTFILE.md
  
tesseract -c page_separator="" $IMAGE $OUTFILE 

# remove any end-of-line hyphenations to re-join words
# (loops over file)
sed -i ':a;N;$!ba;s/-\n//g' $TMPFILE

# mark blank paragraph breaks to re-introduce later
sed -i 's/^\s*$/<BREAK>/g' $TMPFILE

# replace any remaining unneeded newlines with single space
# (loops over file)
sed -i ':a;N;$!ba;s/\n/ /g' $TMPFILE

# add back in paragraph breaks
sed -i 's/<BREAK>/\n\n/g' $TMPFILE

# remove all unneeded leading whitespace
sed -i 's/^\s*//g' $TMPFILE

cat $TMPFILE >> $MDFILE

# cleanup
rm $TMPFILE

# I decided to do everything through the temp file because capturing
# the text in a variable from tesseract lead to unexpected  results
# (sometimes no text, when it would be output to the temp file)