find ./ -type f \( -iname \*.jpg -o -iname \*.png \) -print0 -exec bash -c "editmetadata \"{}\" $currwinid" \; 
