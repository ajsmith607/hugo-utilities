#!/bin/bash

# run as
# source ./me-clip.sh

# writes contents of clipboard to external file
# for use by other scripts

SCRIPTDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
CITEFILE="$SCRIPTDIR/.cite"

CITE=`xclip -sel clip -o`
$CITE >> $CITEFILE

# SAVECITE=false
# regex to check domain: \.[a-z]{2,3}$




