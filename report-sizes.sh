#!/bin/bash

echo "****************"
echo "LARGE DIRS ON DISK:"
du -hs --apparent-size ./content
du -hs --apparent-size ./docs
printf "\n"

printf "APPROX SIZE OF PUSH: "
echo "$(git merge-base HEAD origin/main)..HEAD" | git pack-objects --revs --thin --stdout --all-progress-implied -q | wc -c | numfmt --to iec 
echo "****************"
