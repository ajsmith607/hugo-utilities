#!/bin/bash

# hugo server -D --logFile ../log.txt --disableFastRender --navigateToChanged 
hugo server ${1} --logFile ../log.txt --navigateToChanged --printUnusedTemplates --templateMetrics --templateMetricsHints
