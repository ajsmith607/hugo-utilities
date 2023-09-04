#!/bin/bash

# pass along the commit message and optional force flag


# Hugo user manual suggests completely deleting publish directory
#rm -rf ./docs
#echo "memills.com" > ./docs/CNAME
 
updatehugo.sh "${2}"
report-sizes.sh
push.sh "${1}" 
remotefilesync.sh "full"
echo "TODO: save should have exit code that publish checks"
