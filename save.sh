#!/bin/bash

# run image processing garbage collection 
# to delete old generated files no longer neeeded
hugo --gc

# add new files and
# delete files removed by Hugo garbage collection ( with -A)
git add -A .

# commit and push
git commit -m "$1"
git push origin main 

