#!/bin/bash

FILE=.init.md
if [[ -f "$FILE" ]]; then
    CONTENT=`cat "$FILE"`
    echo -e "$CONTENT" > "$FILE"
fi

mv .init.md .init.bac

