#! /bin/bash 

# given a list of URLs to png images on nyshistoricnewspapers.org,
# download the images, save them to a formatted filename
# and create stub metadata file 

# load URLs or exit if file doesn't exist
URLFILE=urls.txt
[ -f "${URLFILE}" ] || exit 


# read in information on all titles
scriptdir=$(dirname -- "$(readlink -f "${BASH_SOURCE}")")
CSVFILE="${scriptdir}/nyshistoricnewspapers.csv"
titles=() 
while IFS= read -r line 
do
    titles+=("$line")
done < $CSVFILE 


# read in URLs to process
while IFS= read -r url 
do

    IFS="/" read -r pt blank domain na num date ed pg fmt <<< $url 

    # parse date, or failing that, just set to unparsed date
    DATE=$(date -d "${date}" +'%d %b %Y' 2> /dev/null) || DATE=$date
  
    # lookup title and location information.  
    name=""; loc=""
    index=0
    for record in "${titles[@]}"
    do
        IFS="|" read -r tnum name loc <<< "$record"
        [ "$num" =  "$tnum" ] && break 
        ((index++))
    done

    # title case, trim long names and replace spaces with dashes for use in filename
    upname=""
    for word in $name
    do
        upname+=" ${word^}"
    done
    upname="${upname# }"; # remove leading whitespace 

    trimname="${upname:0:20}"
    trimname="${trimname// /-}"

    trimloc="${loc// /-}"
    
    # get page number
    IFS="-" read -r na PG <<< "$pg"
 
    # if URL does not end in png, add it
    fmt="png"
    [[ $url == */"${fmt}"/ ]] || url+="/${fmt}/" 

    basename="${date}-${trimname}-${trimloc}-p${PG}"
    imagefile="${basename}.${fmt}"
    mdfile="${basename}.md"
    
    # download image, saving to generated filename
    wget -O ${imagefile} ${url} 

    # prepend formatted front matter string to file
    citetext="${DATE}, ${upname}, ${loc}, p${PG}, nyshistoricnewspapers.org"
    [ -f "${mdfile}" ] || { touch "${mdfile}" ; } 
    mdcontent="---\ncitation: \"${citetext}.\"\n---\n\n"
    #mdcontent+=`cat "${mdfile}"`
    echo -e "$mdcontent" > "$mdfile"

    sleep 2

done < $URLFILE 
