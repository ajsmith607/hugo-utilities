#!/bin/bash
# shell script to test code

# check to see if this looks like a URL
# this prevents errors if the clipboard is overwritten 
# with figure code still, or something else
# old: \.[a-z]{2,4}$
# new: ((http|https)://)(www.)?[a-zA-Z0-9@:%._\\+~#?&//=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%._\\+~#?&//=]*)

declare -a testURLs=(       "www.google.com" 
                            "http://www.google.com" 
                            "https://www.google.com" 
                            "www.agile-software.com"
                            "http://www.google.com/test/link.php"
                            "https://www.cyberciti.biz/faq/bash-for-loop-array/" 
                            "https://www.geeksforgeeks.org/check-if-an-url-is-valid-or-not-using-regular-expression/" )

declare -a testPatterns=(   '((http|https):\/\/)(www.)?[a-zA-Z0-9@:%._\\+~#?&-_\/\/=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%._\\+~#?&-_\/\/=]*)'
                            '((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[.\!\/\\w]*))?)' 
                            '^(https?|ftp|file)?:\/\/[-A-Za-z0-9\+&@#/%?=~-|!:,.;]*[-A-Za-z0-9\+&@#/%=~-|]$'
                            '(https?|ftp|file)?:\/\/[-A-Za-z0-9\+&@#\/%?=~_-|!:,.;]*[-A-Za-z0-9\+&@#\/%=~_-|]' 
                            '@^(https?|ftp)://[^\s/$.?#].[^\s]*$@iS' 
                            '(https?:\/\/)?(www.)?[-A-Za-z0-9\+&\@#\/%?=~\-|!:,.;]*[-A-Za-z0-9\+&\@#\/%=~\-|]')

for s in "${testURLs[@]}"
do
    echo "testing: $s"
    for p in "${testPatterns[@]}"
    do
        # echo "  - pattern: $p"
        if [[ echo "$s" | sed -n '/(https?:\/\/)?(www.)?[-A-Za-z0-9\+&\@#\/%?=~\-|!:,.;]*[-A-Za-z0-9\+&\@#\/%=~\-|]/p'  ]]; then
            echo "      GOT URL: "
        else
            echo "      NO URL"
        fi
        echo "$s" | sed -n '/$p/p' 
    done
done


echo "http://www.google.com" | sed -n '/(https?:\/\/)?(www.)?[-A-Za-z0-9\+&\@#\/%?=~\-|!:,.;]*[-A-Za-z0-9\+&\@#\/%=~\-|]/p' 



# URL regex, see:
#  - https://gist.github.com/dperini/729294
#  - https://mathiasbynens.be/demo/url-regex
