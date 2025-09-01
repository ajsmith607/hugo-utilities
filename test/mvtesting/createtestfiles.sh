#!/bin/bash

rm -r *.tiff

numfiles=10
for i in $(seq 1 $numfiles)
do
    touch "scan-sidea-$i.tiff"
    touch "scan-sideb-$i.tiff"
done
