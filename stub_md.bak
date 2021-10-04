#!/bin/bash 

DIR=$1
OP=$2
FILE=$3

DATADIR="$PWD/data_files"
MDDIR="$PWD/metadata_files"
CITEFILE="$PWD/.cite"

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

    CITE=`cat $CITEFILE`

    # echo "DATE is $DATE"
    # echo "NAME is $NAME"

    MDCONTENT="---\ncitation: \"$DATE, $NAME, $CITE\"\n---\n"
    echo -e $MDCONTENT > $MDFILE
    code $MDFILE
fi

# test.com