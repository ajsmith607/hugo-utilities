#!/usr/bin/env bash

set -eEuo pipefail
IFS=$'\n\t'
trap 'echo "Error on line $LINENO"; exit 1' ERR

source common.sh

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


# extract individual pages of PDFs as seperate images
if [[ "$extract" == "y" ]]; then
  echo
  echo "EXTRACTING"
  pdftojpg.sh 
fi

# basic filename sanitization 
echo
echo "DETOXING"
detoxify.sh

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


