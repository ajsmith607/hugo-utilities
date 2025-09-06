#!/bin/bash

BASENAME=${1%.*}
IMGNAME="${BASENAME}.jpg";
if [ ! -f "${IMGNAME}" ]; then
    IMGNAME="${BASENAME}.png";
    if [ ! -f "${IMGNAME}" ]; then
        echo "no file found at: ${BASENAME}, either .jpg or .png"
        exit
    fi
fi

echo ${IMGNAME}

