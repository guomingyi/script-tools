#!/bin/bash

###############################################################
path=$(pwd)
tool_path=~/script/tools
arg0=$@


echo "current path:$path"
echo "arg0 :$arg0"
echo "tool_path:$tool_path"

echo "start dex --> jar"
for i in $arg0
do
    echo "do : $tool_path/dex2jar-2.0/d2j-dex2jar.sh $i"
    $tool_path/dex2jar-2.0/d2j-dex2jar.sh $i
done

echo ""
ls -l *.jar *error.zip
echo ""



