#!/bin/bash

# hugo server -D --logFile ../log.txt --disableFastRender --navigateToChanged 
rm ../log.txt
find . -type f -size +10M
hugo server "${1}" --logFile ../log.txt --navigateToChanged --printUnusedTemplates --templateMetrics --templateMetricsHints
