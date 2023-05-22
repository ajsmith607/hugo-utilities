#!/bin/bash

# hugo server -D --logFile ../log.txt --disableFastRender --navigateToChanged 
rm ../log.txt
find ./content -type f -size +6M -exec du -h '{}' + | sort -hr | head -10
hugo server "${1}" --logFile ../log.txt --navigateToChanged --printUnusedTemplates --templateMetrics --templateMetricsHints
