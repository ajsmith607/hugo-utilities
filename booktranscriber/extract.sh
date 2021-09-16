#!/bin/bash
LC_CTYPE=en_US.utf8

INPUT=$1

IFS='%' # preserves whitespace in shell command output (for tesseract)
shopt -s nullglob # avoids matching * if no images are found

# extract images from PDF
convert -units PixelsPerInch -resize 1200x1200 -density 300 -quality 100 $INPUT -scene 1 %d.jpg

# extract text from images and re-organize content for Hugo
for IMAGE in *.jpg
  do 
    SEQNUM=$(basename $IMAGE .jpg)
    echo "SEQNUM: " $SEQNUM

    mkdir -p $SEQNUM
    mv -f $SEQNUM.jpg $SEQNUM/
    
    \cp ./trans_page.md $SEQNUM/index.md
    sed -i "s/seq-num:/seq-num: $SEQNUM/" $SEQNUM/index.md
    sed -i "s/page-img:/page-img: $SEQNUM.jpg/" $SEQNUM/index.md

    TODAY=$(date +"%Y-%m-%d")
    sed -i "s/date:/date: $TODAY/" $SEQNUM/index.md

    TEXT=""
    TEXT="$(tesseract -c page_separator="" $SEQNUM/$SEQNUM.jpg stdout)" 
    TEST="$(echo $TEXT | tr -d '[:space:]')" # is this truly an empty string?
    if [ -n "$TEST" ]
      then
        TEXT="$(echo $TEXT | perl -p -e 's/-\n//')" # remove end of line hyphenations -- sed won't work because it operates line by line even on a var!
        TEXT="$(echo $TEXT | sed 's/^\s*$/<BREAK>/g')" # mark blank paragraph breaks to re-introduce later
        TEXT="$(echo $TEXT | tr '\n\r\f' ' ')" # trim all unneeded trailing whitespace 
        TEXT="$(echo $TEXT | sed 's/^\s*//g')" # remove all unneeded leading whitespace

        echo $TEXT >> $SEQNUM/index.md
        sed -i 's/\s<BREAK>\s/\n\n/g' $SEQNUM/index.md # add back in paragraph breaks
      else
        TEXT=""
    fi

    mogrify -units PixelsPerInch -resize 1000 -density 72 -quality 90 $SEQNUM/$SEQNUM.jpg
    
  done
