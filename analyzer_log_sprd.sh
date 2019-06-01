#!/bin/bash

local=$(pwd)

echo "local path:$local"

search_r=$(find $local -name analyzer.py)

#echo "search:$search_r"

echo "analyzer start.."

for i in $search_r
do
  echo "python $i"
  python $i
done

echo "analyzer done!"
exit 0




