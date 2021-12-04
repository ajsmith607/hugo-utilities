#!/bin/bash

# create markdown metadata files for each image
touchmds.sh

# use filename conventions to populate 
# initial citiation metadata
# appending optional command line argument
citify.sh $1

# manually edit each image's metadata with image preview
manualmeta.sh

# generate fig shortcodes for each image, 
# appending out to a file and appending to clipboard
# if a file is passed, it will append to that file
figify.sh  

