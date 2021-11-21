#!/bin/bash

# pass along the commit message and optional force flag
save.sh "${1}" "${2}"
git push origin main 
echo "TODO: save should have exit code that publish checks"
