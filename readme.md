

## Directories

    - transcribebooks
        - Collection of scripts specifically for volume transcription projects, which follow different conventions from simpler projects.
    
    - archived
        - Obsolete scripts.

    - test
        - Area for test files used in script development. 


## General Scripts

    - textifyscript.sh
        - Runs the script command and once finished, converts its output to plain text

    - previewimage.sh
        - Preview an image whose path is in the clipboard. Used for opening image from path in VIM. 

    - mvplanner.sh
        - Run within a directory, creates a bash script that can be used to bulk move files. 


## Git Scripts

    - publish.sh "COMMITMESSAGE" "true"
        - second argument is optional override of Git check for uncommitted changes. 
        - calls the following scripts:

        - updatehugo.sh "true"
            - Checks for uncommitted changes in dependent repositories, updates Hugo modules and runs the Hugo static site generator.
            - optional argument overrides Git check for uncommitted changes. 

        - push.sh "COMMITMESSAGE"
            - runs commit.sh:
            - commit.sh "COMMITMESSAGE"
                - Does a complete Git tree update and commits.
            - pushes to origin 


## Hugo Scripts

    - newhugosite.sh REPONAME
        - After creating REPONAME at Github, run this script wth REPONAME to create hugo site and commit to Github.

    - run.sh
        - Invokes the hugo server on port 1313.

    - simpleproc.sh
        - Runs the following: 

            - touchmds.sh
                - Creates markdown metadata files for each image in the current directory. Skips existing files. 

            - citify.sh
                - For each metadata file created above, without existing front matter, pre-populate initial metadata based on filename convention.
                - Added metadata is prepended to any existing file content, such as automatically generated transcriptions.

            - editmetadata.sh
                - In the current directory, simultaneously open a metadata file for editing alongside a preview of the corresponding image.
                - Once editing is completed, writing and quitting vi continues the loop through the files. 
                - Passing -t flag will make script track files that have been edited so that large jobs can be restarted without losing one's place. 

            - figify.sh
                - Prepopulate figure shortcodes for all images in current working directory, append to a file called '.figifytmp' and add to the system clipboard.
        
