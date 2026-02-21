#!/bin/bash

set -o pipefail
#config
ROOT_DIR=$(pwd)
htmlFolder="$ROOT_DIR/src/website/" # folder where the html-files are saved with @includes inside
moduleFolder="$ROOT_DIR/src/modules/" # folder where the corresponding modules are saved as html files
newFolder="$ROOT_DIR/dist/website/" # folder where the html files are saved with the modules inside
newModulesFolder="$ROOT_DIR/dist/modules/" # folder where the modules files are saved, if they had a @includes inside here the module wil be copied inside
distDir="$ROOT_DIR/dist/" # dist folder
srcDir="$ROOT_DIR/src/" # dist folder

# @TODO refactor: now that at the beginning the scr dir is completle copied to dist everything could be edited in the dist dir directly

if [[ -e $distDir ]]; then 
    rm -rf $distDir #remove build DIR if exists
    echo "removed old"
    mkdir $distDir
    cp -r $srcDir/* $distDir
    echo "copied from src to dir"
fi

#checks all modules files for modules as well and copy them to the build directory
check_modules() { 

    # create array from all html module files and sending each file to find_in_file
    readarray -t filesArray < <(find "$moduleFolder" -type f -name "*.html" )
    echo "Found: "${#filesArray[@]}" html files:"
    for i in "${filesArray[@]}"; do
        echo "$i"
        find_in_file "$i" $moduleFolder $newModulesFolder $moduleFolder
    done
    echo "done"
}

find_html_files() {
    #finding all files with .html and save them to array
    readarray -t filesArray < <(find "$htmlFolder" -type f -name "*.html" )
    echo "Found: "${#filesArray[@]}" html files:"
    for i in "${filesArray[@]}"; do
        echo "$i"
        find_in_file "$i" $htmlFolder $newFolder $newModulesFolder
    done
    echo "done"

}

#$1 path of the file 
#$2 base dir path htmlFolder or moduleFolder
#$3 dir where to put file newModulesFolder or newFolder
#$4 dir where to look for modules moduleFolder oe newModulesFolder
#looks if file contains @includes and give them to replace_html_module_file
find_in_file() {
    # create array from all @includes in file 
    mapfile -t includesArray < <(grep '@include' "$1" 2>/dev/null || true)
    for i in "${includesArray[@]}"; do
        echo "$i"
    done

    fileScr="${1//$2/}" # eg. /sidethoughts/index.html
    fileName=${fileScr##*/} # eg. index.html
    fileDir=${fileScr%$fileName} #eg. sidethoughts/
    # sends every @includes to replace_html_module_file with some file checks to asure everything is right
    for include in "${includesArray[@]}"; do
        echo "$include"
        if [[ -n $include ]]; then
            echo "found @include in $1"
            moduleName="${include##*-}"
            if [[ -e $moduleFolder/$moduleName ]]; then
                echo "module exist"
                replace_html_module_file $include "$4$moduleName" $1 $3$fileScr "$3$fileDir"
            else
                echo file does not exist
            fi
        else
            echo "empty"
        fi
    done
}


#$1= what module e.g. @include-nav.html
#$2= what module to copy e.g. ../modules/nav.html
#$3 = file to inspect e.g. ../index.html
#$4 = file to create with module e.g. ../build/index.html
#$5 = build dir e.g. . ../build/.../
# replaces @includes-module.html with the module html code from its file
replace_html_module_file() {
    #check if build dir exists if not create
    if [ ! -d "$5" ]; then
        mkdir -p "$5"
        echo "Directory '$5' created."
    else
        echo "Directory '$5' already exists."
    fi    
      
    #check if file ($4) exits already then read and write in this exact file
    if [[ -e $4 ]]; then # if exist then
        echo "overwriting because file exists"
        sed -i "\,$1,r $2" "$4"
    else # if not then copy html with module in new file
    echo $3
        sed "\,$1,r $2" "$3" > "$4"
        echo "file created"
        echo "$1"

    fi

    #remove @include in this file
    sed -i "\,$1,d" "$4"
}

format() {
    readarray -t filesArray < <(find "$newFolder" -type f -name "*.html" )
    for i in "${filesArray[@]}"; do
        npx js-beautify $i --type html --replace --indent-size 2 --max-preserve-newlines 0
    done
}

check_modules
find_html_files
format
