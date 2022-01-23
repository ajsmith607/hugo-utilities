#!/bin/bash

# from https://askubuntu.com/questions/1064344/how-to-convert-script-command-output-into-plain-text
# sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" ${filename} | tr -dc '[[:print:]]\n' > script.txt 

filename=temprecord.txt

script -a ${filename}

# https://github.com/t-matsuo/script-output-converter
script-output-converter ${filename}
