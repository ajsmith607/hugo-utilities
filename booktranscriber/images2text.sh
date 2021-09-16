#!/bin/bash
# ./images2text.sh ./directory_of_images_to_process
# output will be in "generated" directory within the passed directory
# containing markdown files for each images
# and an "images" directory with copies of original files 
# referenced from the corresponding markdown

shopt -s nullglob # avoids matching * if no images are found

SCRIPTDIR=$(dirname $0)
# trim any trailing slashes
INPUTDIR=$(echo $1 | sed 's:/*$::')
DIR=$(pwd)
GENDIR="generated"
FULLPATH=$DIR/$INPUTDIR/$GENDIR
IMAGESDIR="images"

echo "INPUTDIR: " $INPUTDIR
echo "DIR: " $DIR
echo "GENDIR: " $GENDIR
echo "FULLPATH: " $FULLPATH
echo "SCRIPTDIR: " $SCRIPTDIR

# extract text from images and re-organize content for Hugo
for IMAGE in $INPUTDIR/*.jpg
  do 
    SEQNUM=$(basename $IMAGE .jpg)
    # echo $SEQNUM ": " $IMAGE

    SAVETO=$FULLPATH
    
    # most distros alias cp to run in interactive mode by default
    # the backslash escapes this, forcing overwrites    
    mkdir -p $FULLPATH/$IMAGESDIR
    \cp $INPUTDIR/$SEQNUM.jpg $FULLPATH/$IMAGESDIR
    
    \cp $SCRIPTDIR/trans_page.md $FULLPATH/$SEQNUM.md
    sed -i "s/seq-num:/seq-num: $SEQNUM/" $FULLPATH/$SEQNUM.md
    sed -i "s/fileref:/fileref: $IMAGESDIR/$SEQNUM.jpg/" $FULLPATH/$SEQNUM.md

    TODAY=$(date +"%Y-%m-%d")
    sed -i "s/date:/date: $TODAY/" $FULLPATH/$SEQNUM.md

    extracttext.sh $FULLPATH $IMAGESDIR $SEQNUM
    
    # mogrify -units PixelsPerInch -resize 1000 -density 72 -quality 90 $SAVETO/$SEQNUM.jpg
    
  done
