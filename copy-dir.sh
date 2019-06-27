#!/bin/bash

# for debug.

function echo_red()
{
    echo -e "\e[1;31m$*\e[0m"
    exit -1;
}

function echo_green()
{
    echo -e "\e[1;32m$*\e[0m"
}

key="$1"
destpath="$2"
pathlist=`find . -name "$key"`

echo "pathlist=$pathlist"

for i in $pathlist
do
    #echo "i=$i"
    let pos=`echo "$i" | awk -F ''/'' '{printf "%d", length($0)-length($NF)}'`
    j=${i:0:$pos}
    #echo "j=$j"

    if [ -d $i ] ; then
        if [ ! -d  $destpath/$j ] ; then
            # echo "mkdir -p $destpath/$j"
            mkdir -p  $destpath/$j 
        fi
        echo "cp -a $i  $destpath/$j"
        cp -a $i  $destpath/$j 
    else
        cp -r -f $i $destpath/$j 
    fi

done;

echo_green "提取完成: "
tree -L 5 $destpath


















