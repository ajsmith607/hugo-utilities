#!/bin/bash

PUBDIR="./test/cname/public"
#PUBDIR="./docs"
KEEP=CNAME

# ** SETUP 
mkdir -p "$PUBDIR"
touch "${PUBDIR}/CNAME"  "${PUBDIR}/this.jpg"  "${PUBDIR}/that.jpg" "${PUBDIR}/other.md"

# ** TEST
if [ -d "$PUBDIR" ]; then
    echo "found $PUBDIR" 
    # delete ALL contents in this directory EXCEPT CNAME 
    # CNAME doesn't get regenerated with Hugo files, but is needed by Github Pages 
    # to configure DNS.
    find "$PUBDIR" -mindepth 1 ! -name "CNAME" -exec rm -vir {} +
fi

# ** REPORT
echo "FINAL:"
ls -al "$PUBDIR"
