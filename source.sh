#!/bin/bash

# fieldinfo format:
#   label_size_changes
#
# where:
#   size: the size of each value in the field
#   changes: indicates how to transform the value:
#       e: expand the value
#       q: quote the value
#       d: datify the value according to the date pattern defined above

fieldinfo=(
    seq_0
    copyNum_0
    pageNum_0
    documentPart_2_e
    pageArea_2_e
    flags_0_e
    dates_8_d
    )

pagelevelfields=(seq, pageNum, dates)

declare -A expands 
expands[p]="is photograph"
expands[s]="is scanned"
expands[n]="no edges visible"
expands[t]="top edge visible"
expands[b]="bottom edge visible"
expands[l]="left edge visible"
expands[r]="right edge visible"
expands[f]="visible fold, crease"
expands[w]="is two page spread"
expands[c]="is closeup"
expands[pg]="interior page"
expands[aa]="front cover"
expands[ab]="inside front cover"
expands[zy]="inside back cover"
expands[zz]="back cover"
expands[tp]="title page"
expands[tc]="table of contents"
expands[dc]="dedication"
expands[cc]="all content is visible in the image" 
expands[q1]="first quadrant" 
expands[q2]="second quadrant"
expands[q3]="third quadrant"
expands[q4]="fourth quadrant"


