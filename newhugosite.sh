#!/bin/bash

# create new repository at Github with REPONAME
# then call this script with REPONAME as argument

# for convenience, a function similar to Perl
die() { echo "$*" 1>&2 ; exit 1; }

USERNAME=ajs17
REPONAME=$1
ORIGIN=git@github.com:"${USERNAME}"/"${REPONAME}".git

hugo new site "${REPONAME}" # creates REPONAME directory
cd "${REPONAME}" || die "no directory named ${REPONAME}"
printf ".envrc\n" > .gitignore 

hugo mod init github.com/"${USERNAME}"/"${REPONAME}"
git init
git add *
git commit -m "first commit"
git branch -M main
git remote add origin "${ORIGIN}"
git remote set-url origin "${ORIGIN}"
git push -u origin main

echo "REMEMBER to copy over current .envrc"


