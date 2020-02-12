#!/bin/bash

# odex-reverse.sh 1.odex 2.odex .. n.odex
# https://github.com/JesusFreke/smali/releases
# https://bitbucket.org/JesusFreke/smali/downloads/

# odex-reverse.sh ./framework/oat/arm/media_cmd.odex ./framework/arm/

destOdexFile=$1
bootOatDir=$2
verno=2.3.4
baksmali=/home/android/github/script-tools/tools/baksmali-${verno}.jar
smali=/home/android/github/script-tools/tools/smali-${verno}.jar
dex2jar=/home/android/github/script-tools/tools/./dex2jar-2.1/d2j-dex2jar.sh

# odex -> smail
echo "java -jar $baksmali deodex $destOdexFile -d $bootOatDir"
java -jar $baksmali deodex $destOdexFile -d $bootOatDir

# smail -> dex
echo "java -jar $smali assemble out "
java -jar $smali assemble out 

# dex -> jar
echo "$dex2jar --force  out.dex"
$dex2jar --force out.dex

# view jar http://java-decompiler.github.io/






exit 0

function odex2jar()
{
odex=$1

# del old files
echo "rm -rf out-$odex new-$odex*dex2jar.jar"
rm -rf out-$odex new-$odex*dex2jar.jar

# odex =》smali
echo "java -jar $tool_path/baksmali-${verno}.jar -d ./ -a 23 -c $boot_oat -x $odex"
java -jar $tool_path/baksmali-2.1.3.jar -d ./ -a 23 -c $boot_oat -x $odex

mv out out-$odex

# smali =》 dex
echo "java -jar $tool_path/smali-${verno}.jar -o new-$odex.dex out-$odex"
java -jar $tool_path/smali-2.1.3.jar -o new-$odex.dex out-$odex

# dex =》jar
echo "$tool_path/dex2jar-2.0/d2j-dex2jar.sh ./new-$odex.dex"
$tool_path/dex2jar-2.0/d2j-dex2jar.sh ./new-$odex.dex

}

###############################################################

mypath=$0
let pos=`echo "$mypath" | awk -F ''/'' '{printf "%d", length($0)-length($NF)}'`
mypath=${mypath:0:$pos-1}

echo $mypath

path=$(pwd)
tool_path=$mypath/tools
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










