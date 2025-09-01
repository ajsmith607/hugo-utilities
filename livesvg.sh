#!/bin/bash

SVGBASENAME="${1}"
SVGFILE="${SVGBASENAME}.php"

if [ ! -f "index.php" ]; then
INDEX=$(cat <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <script>
        setInterval(() => {
            location.reload();
        }, 1000);  // Reload every 2 seconds
    </script>
</head>
<body>
<?php
\$SVG = basename(\$_GET['svg']) . ".php"; // Removes any directory paths
include("\$SVG"); 
?>
</body>
</html> 
EOF
)
echo "$INDEX" > index.php
fi

if [ ! -f "${SVGFILE}" ]; then
SVG=$(cat <<EOF
<svg viewBox="0 0 100 100" width="400" height="400" 
     xmlns="http://www.w3.org/2000/svg"
     xmlns:xlink="http://www.w3.org/1999/xlink">

<style>
svg {
    --fcolor: black; 
    --bcolor: white;
    background-color: var(--bcolor);
    stroke: var(--fcolor);
    stroke-width: .0625;
    fill: none;
}
text { 
    font-family: sans-serif; 
    font-size: 6%; 
    text-anchor: middle;
    dominant-baseline: middle;
    stroke-width: 0; 
    fill: var(--fcolor); 
}
</style>



</svg>
EOF
)
    echo "$SVG" > "${SVGFILE}"
fi

serveraddress="localhost:8080"
php -S "$serveraddress" & 
php_pid=$!
google-chrome --new-window "http://$serveraddress/index.php?svg=${SVGBASENAME}" --disable-application-cache --incognito &
# open a new terminal window and run a command in it
kitty --detach vi +':normal! G-3' "${SVGBASENAME}.php" &

# Trap Ctrl-C to stop the PHP server when done
trap 'echo Stopping PHP server...; kill $php_pid; exit' INT
# Wait indefinitely, allowing PHP server to run
wait $php_pid
