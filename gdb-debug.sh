#!/bin/bash

function echo_red()
{
    echo -e "\e[1;31m$*\e[0m"
    exit -1;
}

function echo_green()
{
    echo -e "\e[1;32m$*\e[0m"
}


mydir=$(dirname $0)
#echo "mydir=$mydir"

#被调试的可执行程序
execfile=$1

#符号信息目录
symbols=$2

#${string/%substring/replacement}
symbols=${symbols/%\//''}
#echo "symbols=$symbols"

symbols_abs_path=$PWD/"$symbols/vendor"
execfile_path=$PWD/`find $symbols -name $execfile`

#search_path1=`find $symbols -name lib`
search_path2=`find $symbols -name lib64`
search_path3+=$search_path1
search_path3+=$search_path2

for i in $search_path3
do
j+="$PWD/$i:"
done;

symbols_search_path=${j/%\:/''}

#echo "symbols_search_path=$symbols_search_path"
#exit

#echo "symbols_abs_path=$symbols_abs_path"
#echo "execfile_path=$execfile_path"

# 从前开始截取匹配第一个字符串
execdest="${execfile_path#*system}"
if [ "y$execdest" == "y$execfile_path" ]; then
    execdest="${execfile_path#*vendor}"
    if [ "y$execdest" == "y$execfile_path" ]; then
        echo_red "not found dest:$execfile_path"
	else
		execdest="vendor$execdest"
    fi
else
    execdest="system$execdest"
fi

echo_green "execdest=$execdest"


# 准备工作.
adb root && adb remount
adb push $mydir/gdbserver64 system/bin/gdbserver64

#启动gdbserver和tcp转发.#加&开新线程，否则会阻塞.
port=1779
echo "adb shell system/bin/gdbserver64 :$port $execdest &"
adb shell system/bin/gdbserver64 :$port $execdest &

echo "adb forward tcp:$port tcp:$port"
adb forward tcp:$port tcp:$port

#默认设置加载命令.
#echo "target remote :$port" > ~/.gdbinit
#echo "set solib-search-path $PWD/out/target/product/c330ae/symbols/vendor/lib64/" > ~/.gdbinit
#echo "set solib-absolute-prefix $PWD/out/target/product/c330ae/symbols/" >> ~/.gdbinit
#echo "-" >> ~/.gdbinit

#启动调试.一定要弄对gdb和gdbserver的版本对应关系，否则会链接失败!!!
#  Remote side has terminated connection.  GDBserver will reopen the connection

#cd /home/android/driver/c330/LA.UM.7.6.2/LINUX/android/prebuilts/gdb/linux-x86/bin
#echo "$execfile_path"

/home/android/driver/c330/LA.UM.7.6.2/LINUX/android/prebuilts/gdb/linux-x86/bin/gdb $execfile_path





