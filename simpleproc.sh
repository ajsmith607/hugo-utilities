#!/bin/bash

# can be called with a single file propogated through other scripts
# otherwise, each script will operate on all files in current directory, recursively
# because each script is a separate function, they can be run independently
# and are written to be non-destructive.

source ICE.sh && ice_run "$@" || exit 1
#     2. Optionally define:
#          myapp_doc   — custom help text (optional)
#          myapp.template — optional template file

echo
echo "CONFIGURATION"
echo "extract: $extract"
echo "citesub: $citesub"
echo "citepre: $citepre"
echo "citepost: $citepost"
echo

if [[ -n "$file" ]]; then
  if [[ ! -f "$file" ]]; then
    echo "Error: File not found: $file" >&2
    exit 1
  fi
fi

# extract individual pages of PDFs as seperate images
if [[ "$extract" == "y" ]]; then
  echo
  echo "EXTRACTING"
  pdftojpg.sh 
fi

# basic filename hygene
echo
echo "DETOXING"
if [[ -n "$file" ]]; then
    detox -r "$file" 
else
    detox -r . 
fi

# review large image files
echo
echo "LARGE IMAGE REVIEW"
review-large-images.sh

# create markdown metadata files for each image
echo
echo "TOUCHING METADATA FILES"
touchmds.sh

# use filename conventions to populate 
# initial citiation metadata
# appending optional command line argument
echo
echo "CITIFY"
source citify.sh

echo
echo "METADATA EDIT"
editmetadata.sh 

echo "FIGIFY"
figify.sh


