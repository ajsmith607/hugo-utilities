#!/bin/bash
# run in top level headless resource folder 
# containing /data and /metadata folders
# watch for new images and when one is found,
# create a corresponding stub metadata file (if it doesn't already exist)
# the filename of which is based on a naming convention on the image file
#
# and add the appropriate shortcode to the clipboard

# SCRIPTDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

DATADIR="$PWD/data_files"
MDDIR="$PWD/metadata_files"
CITEFILE="$PWD/.cite"

touch $CITEFILE

CLIP=`xclip -sel clip -o`
echo "clip contains: $CLIP"
# check to see if this looks like a URL
# this prevents errors if the clipboard is overwritten 
# with figure code still, or something else
if [[ "$CLIP" =~ \.[a-z]{2,3}$ ]]; then
  echo "Setting clipped citation: $CLIP"
  echo $CLIP >> $CITEFILE
fi

echo "$CLIP will now be used until changed with me-clip"

# default of space, tab and nl
unset IFS                                 

# Wait for filesystem events below the data_files directory       
# -m will not work! always crashes with: read error: 0: Resource temporarily unavailable
# luckily, this runs infrequently, so this is a brute force workaround

while true; do 

  inotifywait -r -e create $DATADIR  |
  while read -r DIR OP FILE; do 
    echo "detected changed file: $FILE in $DIR"
    RELDIR=${DIR/$DATADIR/}
    RELDIR=${RELDIR/\//}
    echo "RELDIR: $RELDIR"

    BASENAME=${FILE%.*}
    # echo "basename: $BASENAME"
    MDFILE=$MDDIR/$RELDIR$BASENAME.md
    # echo "MDFILE: $MDFILE"

    mkdir -p $MDDIR/$RELDIR
    if [[ -f $MDFILE ]]; then 
      echo "MDFILE exists, won't touch"
      continue
    else
      touch $MDFILE

      DATE=`echo $BASENAME | cut -c1-10`
      DATE=`date -d $DATE  +'%d %b %Y'`
      NAME=`echo $BASENAME | cut -c12-`
      NAME=${NAME//-/ }
      
      SRCBASEDOMAIN=`tail -1 $CITEFILE`
      # echo "DATE is $DATE"
      # echo "NAME is $NAME"

      MDCONTENT="---\ncitation: \"$DATE, $NAME, $SRCBASEDOMAIN\"\n---\n"
      echo -e $MDCONTENT > $MDFILE
      echo "opening $MDFILE"
      nvim $MDFILE
    fi
    
    printf $'{{%% mefig "%s" /%%}}' $RELDIR$BASENAME | xclip -sel clip
  done

done

# test.com
# read error: 0: Resource temporarily unavailable

