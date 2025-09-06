#!/bin/bash

# called from vim using
# map <leader>c yy:r ! explode-cite.sh<CR> 
# au FileType ghmarkdown map <leader>c ddk:r ! explode-cite.sh<CR>

TEXT=$(xsel -ob)
echo "#" "${TEXT}" 

# TEXT='citation: "14 Oct 1896, The Ithaca Daily Journal (Ithaca NY), p6, nyhistoricnewspapers.org."'

# whittle down to quoted text 
TEXT=${TEXT#*'"'}; TEXT=${TEXT%'"'*} 

# start parsing fields and massaging data
# use xargs as easy way to trim trailing and leading whitespace
IFS=',' 
read -r date voltitle publocation pages quaddress url <<< "${TEXT}" 

IFS=' '
read -r day month year <<< "${date}"
# use xargs to trim whitespace from variables
day=$(echo ${day} | xargs )
year=$(echo ${year} | xargs )
month=$(echo ${month} | xargs )
# convert month 3 letter abbreviation into 0 padded integer
month=$(date -d "${month} ${day} ${year}" "+%m")

voltitle=$(echo ${voltitle} | xargs )

publocation=$(echo ${publocation} | xargs )
# re-insert space for state
pos=-3
publocation="${publocation:0:pos}${publocation:pos}"

# this code accomodated an older style citation format standard that was used
#IFS='('
#read -r voltitle publocation <<< "${publication}"
#voltitle=$(echo $voltitle| xargs )
#publocation=${publocation%')'*} 
#publocation=$(echo ${publocation} | xargs )

pages=${pages/p/}
pages=$(echo ${pages} | xargs )

quaddress=$(echo ${quaddress} | xargs )
if [[ "$quaddress" == q* ]]
then
    quaddress=${quaddress/q/}
    quaddress=${quaddress%'.'} 
    url=${url%'.'} 
else
    url=${quaddress%'.'} 
    quaddress=""
fi
url=$(echo ${url} | xargs )

# output new citation fields
echo "pubdate: " "\"${year}-${month}-${day}\""
echo "author: "
echo "title: "
echo "voltitle: " "\"${voltitle}\"" 
echo "publocation: " "\"${publocation}\"" 
echo "pages: " "\"${pages}\"" 
echo "quaddress: " "\"${quaddress}\"" 
echo "source: " "\"${url}\"" 
echo "media: " "\"\"" 

