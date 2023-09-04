#!/bin/bash

# basic filename hygene
detox -r ./* 

# extract individual pages of PDFs as seperate images
pdftojpg.sh

# download any saved URLS
# dl-nys.sh

# optimize large image files
process-large-images.sh 5M

# create markdown metadata files for each image
touchmds.sh

# use filename conventions to populate 
# initial citiation metadata
# appending optional command line argument
citify.sh "${1}"

# manually edit each image's metadata with image preview
editmetadata.sh

# generate fig shortcodes for each image, 
# appending out to a file and appending to clipboard
# if a file is passed, it will append to that file
figify.sh  

