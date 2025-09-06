#!/bin/bash

# called from vim using
# map <leader>c yy:r ! explode-cite.sh<CR> 

ocrimage.sh $(get-image-name.sh ${1})  


#find ./ -type f \( -iname "$BASENAME".jpg -o -iname "$BASENAME".png \) -printf "%P\0" | while read -rd $'\0' IMGFILE 
#do
#    echo "IMGFILE: " "$IMGFILE"
#    #echo ocrimage.sh "$IMGFILE"
#done

