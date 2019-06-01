#!/bin/bash

# odex-reverse.sh 1.odex 2.odex .. n.odex

function odex2jar()
{
odex=$1

# del old files
echo "rm -rf out-$odex new-$odex*dex2jar.jar"
rm -rf out-$odex new-$odex*dex2jar.jar

# odex =》smali
echo "java -jar $tool_path/baksmali-2.1.3.jar -d ./ -a 23 -c $boot_oat -x $odex"
java -jar $tool_path/baksmali-2.1.3.jar -d ./ -a 23 -c $boot_oat -x $odex

mv out out-$odex

# smali =》 dex
echo "java -jar $tool_path/smali-2.1.3.jar -o new-$odex.dex out-$odex"
java -jar $tool_path/smali-2.1.3.jar -o new-$odex.dex out-$odex

# dex =》jar
echo "$tool_path/dex2jar-2.0/d2j-dex2jar.sh ./new-$odex.dex"
$tool_path/dex2jar-2.0/d2j-dex2jar.sh ./new-$odex.dex

}

###############################################################
path=$(pwd)
tool_path=~/work/script/tools
arg0=$@
arg=$1
boot_oat=./boot.oat

if [ "$arg0" = "boot.oat" ] ; then
    echo "start oat --> jar"
    java -jar $tool_path/oat2dex.jar boot boot.oat
    exit 0
fi

echo "current path:$path"
echo "arg0 :$arg0"
echo "tool_path:$tool_path"

#exit  0

echo "start odex --> jar"
for i in $arg0
do
    echo "do :$i"
    odex2jar $i
done










