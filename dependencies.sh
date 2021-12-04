#! /bin/bash
# RUN UNDER sudo -H

type -P "pip" &>/dev/null || echo "To install Vimiv, python and pip are required."

# --- begin dependencies
pip install vimiv 
apps="xsel xdotool"
# --- end dependencies

for app in $apps
do
  apt --assume-yes install $app
done



