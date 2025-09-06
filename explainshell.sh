#!/bin/bash

# from Pure Bash Bible
urlencode() {
    # Usage: urlencode "string"
    local LC_ALL=C
    for (( i = 0; i < ${#1}; i++ )); do
        : "${1:i:1}"
        case "$_" in
            [a-zA-Z0-9.~_-])
                printf '%s' "$_"
            ;;

            *)
                printf '%%%02X' "'$_"
            ;;
        esac
    done
    printf '\n'
}
export -f urlencode # now visible to bash subshell 

code=$(xsel -ob)
param=$(urlencode "${code}")
url="http://explainshell.com/explain?cmd=${param}"
google-chrome "${url}" > /dev/null 2>&1
