#!/bin/bash

# update Git working tree
isingitrepo="$(git rev-parse --is-inside-work-tree 2> /dev/null)"
[ "$isingitrepo" == "true" ] && { git add -A . ; echo "\nThe Git repo tree has been updated accordingly.\n"; }
# [ "$isingitrepo" == "true" ] && { echo "\nThe Git repo tree has been updated accordingly.\n"; }
