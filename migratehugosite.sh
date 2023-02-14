#!/bin/bash

USERNAME="ajs17"
REPONAME="${1}"
ORIGIN=git@github.com:"${USERNAME}"/"${REPONAME}".git

printf ".envrc\nresources\n" > .gitignore 

git init
git add *
git commit -m "first commit of new memills repository"
git branch -M main
git remote add origin "${ORIGIN}"
git remote set-url origin "${ORIGIN}"
git push -u origin main



