#!/bin/bash

if [ -n "$1" ] ; then
  var="-s $1"
  echo device: $1
fi
echo "adb shell cat /proc/meminfo & dumpsys meminfo"
# exit 0
memav=$(adb $var shell cat /proc/meminfo|grep "MemAvailable:")
echo $memav > .tmp1
mavailable=$(cat .tmp1|awk '{print $2}')
let i=$((mavailable))
let i2=i/1024
echo -e "MemAvailable:\033[32m $i(KB)/$i2(MB) \033[0m"

cached=$(adb $var shell dumpsys -t 30 meminfo|grep "K: Cached")
echo $cached > .tmp2
cached_pss=$(cat .tmp2|awk '{print $1}')
cached_pss=${cached_pss/','/}
cached_pss=${cached_pss/'K:'/}
let j=$((cached_pss))
let j2=j/1024
echo -e "Cached:\033[32m $j(KB)/$j2(MB) \033[0m"

let k=i+j
let k2=i2+j2
echo -e "Total:\033[31m $k(KB)/$k2(MB) \033[0m"
echo ""

exit 0




