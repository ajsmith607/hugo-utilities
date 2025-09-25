#!/bin/bash
# Usage: get-image-name.sh path/to/basename (no extension)
echo "get-image-name.sh: ${1}"
BASENAME=${1%.*}
EXTS=("jpg" "jpeg" "png" "gif" "tif" "tiff" "bmp" "webp")

for ext in "${EXTS[@]}"; do
    IMGNAME="${BASENAME}.${ext}"
    if [ -f "$IMGNAME" ]; then
        realpath "$IMGNAME"
        exit 0
    fi
done

echo "no file found at: ${BASENAME}, tried: ${EXTS[*]}" >&2
exit 1




