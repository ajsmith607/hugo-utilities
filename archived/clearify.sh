#!/bin/bash

# between runs of processing images, 
# this will clear the .figifytmp file and the clipboard

printf "" | tee ".figifytmp" | xsel -b
