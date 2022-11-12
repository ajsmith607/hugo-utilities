#!/bin/bash

git add -A .
commit.sh "${1}"
git push origin main 
