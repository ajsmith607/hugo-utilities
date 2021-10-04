#!/bin/bash

depRepo="../hugo-min-components"
statusCom="git -C ${depRepostatus} --porcelain --untracked-files=no" 
if [[ $statusCom ]]; then
    echo "there are uncommitted changes in ${depRepo}"
    echo [[ $statusCom ]]
    exit
fi

