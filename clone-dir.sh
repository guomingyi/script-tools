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
clonen="$3"
pathlist=`find . -name "$key"`

echo "pathlist=$pathlist"

for i in $pathlist
do
    #echo "i=$i"
    let pos=`echo "$i" | awk -F ''/'' '{printf "%d", length($0)-length($NF)}'`
    j=${i:0:$pos}
    #echo "j=$j"

    if [ -d $i ] ; then
        if [ ! -d  $destpath/$j/$clonen ] ; then
            # echo "mkdir -p $destpath/$j"
            mkdir -p  $destpath/$j/$clonen 
        fi
        echo "cp -a $i  $destpath/$j/$clonen"
        cp -a $i/*  $destpath/$j/$clonen 
    else
        cp -r -f $i $destpath/$j/$clonen 
    fi

done;

echo_green "克隆完成: "
tree -L 6 $destpath


















