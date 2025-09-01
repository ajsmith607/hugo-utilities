#!/bin/bash
 
# remove any end-of-line hyphenations to re-join words
# (loops over file)
sed -i ':a;N;$!ba;s/-\n//g' "$1" 

# mark blank paragraph breaks to re-introduce later
sed -i 's/^\s*$/<BREAK>/g' "$1"

# replace any remaining unneeded newlines with single space
# (loops over file)
sed -i ':a;N;$!ba;s/\n/ /g' "$1"

# add back in paragraph breaks
sed -i 's/<BREAK>/\n\n/g' "$1"

# remove all unneeded leading whitespace
sed -i 's/^\s*//g' "$1"

