#!/bin/bash
# run in top level headless resource folder 
# containing /data and /metadata folders
# evaluates all resource files to discover and report:
#   - metadata files without corresponding images
#   - images without corresponding metadata files

find $PWD/metadata -type f \( -iname "*.md" ! -iname "*index.md" \) > md.txt 
# use pipes as expression separators here because path when $PWD expands contains slashes
sed -i "s|$PWD/||g" md.txt
sed -i "s/.md//g" md.txt 
sort -o md.txt md.txt 

find "$PWD/data" -type f \( -iname "*.jpg" -o -iname "*.png" \) > img.txt 
sed -i "s|$PWD/data/||g" img.txt 
sed -i "s/.jpg//g" img.txt 
sed -i "s/.png//g" img.txt 
sort -o img.txt img.txt 

OUTFILE="comm.txt"

echo -e "Missing images: \n" > $OUTFILE
comm -23 md.txt img.txt >> $OUTFILE

echo -e "\nMissing md files: \n" >> $OUTFILE
comm -13 md.txt img.txt >> $OUTFILE

# comm -13 md.txt img.txt > touch.sh

echo -e "\nUnused resources: \n" >> $OUTFILE
comm -12 md.txt img.txt > all.txt
while read -r LINE; do 
  if grep -q -r --exclude-dir=section-resources $LINE .. ; then
    continue
  else 
    echo $LINE >> $OUTFILE
  fi
done < all.txt

#rm md.txt img.txt 
echo "See $OUTFILE for saved list of compared files"