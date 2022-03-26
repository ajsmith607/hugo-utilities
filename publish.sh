#!/bin/bash

# pass along the commit message and optional force flag
updatehugo.sh "${2}"
push.sh "${1}" 
echo "TODO: save should have exit code that publish checks"
