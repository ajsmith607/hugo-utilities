INPUT=$1
BASENAME="${INPUT%.*}_images"


if [ -d "$BASENAME" ]; then
    rm -rf "$BASENAME"
fi

mkdir -p $BASENAME

# extract images from PDF
# convert -units PixelsPerInch -resize 1200x1200 -density 300 -quality 100 $INPUT -scene 1 $BASENAME/%d.jpg
convert -units PixelsPerInch -density 300 -quality 100 $INPUT -scene 1 $BASENAME/%d.jpg


# If you get the following error when running the code:
#    convert-im6.q16: attempt to perform an operation not allowed by the security policy `PDF' @ error/constitute.c/IsCoderAuthorized/408.
# open: /etc/ImageMagick-X/policy.xml
#  add: <policy domain="coder" rights="read | write" pattern="PDF" />z
#       just before </policymap>

# mogrify -brightness-contrast 0x30 *.jpg

