#!/bin/bash

# hugo server -D --logFile ../log.txt --disableFastRender --navigateToChanged 
compile-assets.sh
find ./content -type f \( -iname \*.jpg -o -iname \*.png \) -size +6M -exec du -h '{}' + | sort -hr | head -10
# hugo server "${1}" --navigateToChanged 

HUGO_CACHEDIR=/run/user/$(id -u)/hugo_cache

# hugo server "${1}" --cleanDestinationDir --gc --disableFastRender=false --noHTTPCache --navigateToChanged --logLevel info 
hugo server "${1}" --noHTTPCache --disableFastRender=false --navigateToChanged 

# for large projects, increase number of inotify watchers when running server:
# echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
