#!/bin/bash

echo "****************"
echo "10 LARGEST FILES OVER 5M ON DISK:"
# find ./ -type f \(-iname \*.jpg -o -iname \*.png \) -size +"$FILESIZE"  | wc -l

find ./content -type f -size +6M -exec du -h '{}' + | sort -hr | head -10
printf "\n"

printf "REPO INFO: "
# echo "$(git merge-base HEAD origin/main)..HEAD" | git pack-objects --revs --thin --stdout --all-progress-implied -q | wc -c | numfmt --to iec 
git count-objects -vH
echo "****************"
