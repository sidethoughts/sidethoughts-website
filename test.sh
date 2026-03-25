#!/bin/bash

#goal building the file managmenent mimic module
# for every index.html, except the root one, create a module

#steps:
# get all positions of index.html files, maybe recursive / scan all folders and create modules



ROOT_DIR=$(pwd)
htmlFolder="$ROOT_DIR/src/website/" # folder where the html-files are saved with @includes inside
homeFolder="$ROOT_DIR/src/website/home/" # home folder in src folder
moduleFolder="$ROOT_DIR/src/modules/" # folder where the corresponding modules are saved as html files
newFolder="$ROOT_DIR/dist/website/" # folder where the html files are saved with the modules inside
newModulesFolder="$ROOT_DIR/dist/modules/" # folder where the modules files are saved, if they had a @includes inside here the module wil be copied inside
distDir="$ROOT_DIR/dist/" # dist folder
srcDir="$ROOT_DIR/src/" # dist folder


get_files() {
    readarray -t indexFilesArray < <(find "$homeFolder" -type f -name "index.html" )
    #echo "Found: "${#indexFilesArray[@]}" html files:"
    for i in "${indexFilesArray[@]}"; do
        get_data "$i"
    done
    #echo "done"
}

get_data() {
    #echo " files from "${1//"$htmlFolder"/"/"}" :"
    filePath="${1%index.html}" #get file path
    readarray -t filesArray < <( ls $filePath | grep -v "index.html")
    #echo "Found: "${#filesArray[@]}" files:"
    count=0

    for i in "${filesArray[@]}"; do
        date=$(git log -1 --format="%as" -- "${filePath%/*}/$i")
        path=${filePath//"$htmlFolder"/"/"}$i
        #echo "$i,$path,$date"
        filesArray[$count]="$i,$path,$date"
        count=$((count + 1))
    done
    mapfile -t sorted < <(printf "%s\n" "${filesArray[@]}" | sort -t',' -k3 -r)
    create_module "${sorted[@]}"
}

create_module() {
    echo "create_module"
    arr=("$@")
    date=${1##*,}  # => date
    temp=${1%,$date} # => filename,filepath
    filepath=${temp##*,}  # => filepath
    filename=${temp##*/} # => filename
    modulefilepath=${filepath%/$filename}
    modulename=${modulefilepath##*/}
    parentfilepath=${modulefilepath%$modulename}  # => filepath
    parentfilepathfull="${htmlFolder::-1}$parentfilepath"
    parentdate=$(git log -1 --format="%as" -- "${filePath%/*}/$i")

    echo "modulename  $modulename $modulefilepath $parentfilepathfull"
    modulePath=$newModulesFolder"filemanagment/"$modulename".html"
    touch $modulePath
    echo "<div class=\"file\">" >> $modulePath
    echo "<h2 class=\"mtb2\">files</h2>" >> $modulePath
    echo "<div class=\"file-item mtb2\">" >> $modulePath
    echo "  <h3 class=\"file-item-file m0 pb1\">../</h3>" >> $modulePath
    echo "  <p class=\"file-item-date mb0 mt-1\">last modified: ${parentdate//-/.}</p>" >> $modulePath
    echo "  <div class=\"pl3\">" >> $modulePath
    echo "    <p class=\"file-item-path m0\"><a href=\"$parentfilepath\">$parentfilepath</a></p>" >> $modulePath
    echo "  </div>" >> $modulePath
    echo "</div>" >> $modulePath

    echo "created $modulePath"
    for i in "${arr[@]}";do
        # $i = #filename,filepath,date
        date=${i##*,}  # => date
        temp=${i%,$date} # => filename,filepath
        filepath=${temp##*,}  # => filepath
        filename=${temp##*/} # => filename

        #echo "separeted $date $filepath $filename" #filename,filepath,date

        #dir=${src%$base}  => "/path/to/" (dirpath)
        echo "<div class=\"file-item mtb2\">" >> $modulePath
        echo "  <h3 class=\"file-item-file m0 pb1\">$filename</h3>" >> $modulePath
        echo "  <p class=\"file-item-date mb0 mt-1\">last modified: ${date//-/.}</p>" >> $modulePath
        echo "  <div class=\"pl3\">" >> $modulePath
        echo "    <p class=\"file-item-path m0\"><a href=\"$filepath\">$filepath</a></p>" >> $modulePath
        echo "  </div>" >> $modulePath
        echo "</div>" >> $modulePath

    done
    echo "</div>" >> $modulePath

}

if [[ -e $distDir ]]; then 
    rm -rf $distDir #remove build DIR if exists
    echo "removed old"
fi

mkdir $distDir
cp -r $srcDir/* $distDir
echo "copied from src to dir"

mkdir $newModulesFolder"filemanagment/"


get_files
# ls 
# ls -l

# echo "README"
# git log -1 --format="%ad" --date=iso -- "./README.md"
# echo "build.sh format=%ad"
# git log -1 --format="%ad" --date=short -- "./build.sh"
# echo "build.sh format=fuller"
# git log -1 --format="%fuller" --date=short -- "./build.sh"
# echo "build.sh format=as"
# git log -1 --format="%as" -- "./build.sh"
# echo "src/website/home/index.html first commit"
# git log --reverse --format="%as" -- "src/website/home/index.html"  | head -1