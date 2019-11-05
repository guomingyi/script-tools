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

function reset_port()
{
    port=$1
    pid=`ps aux |grep "$port" |grep "/data/gdbserver" |awk '{print $2}'`
    if [ ! "y$pid" == "y" ]; then
        echo "reset port: kill -9 $pid"
        kill -9 $pid
    fi
}

function create_gdbinit_cmd()
{
    cmd="$1"
    ssp="$2"
    po="$3"
    echo "define $cmd" > $GDBINIT
    echo "set solib-search-path $ssp" >> $GDBINIT
    echo "set solib-absolute-prefix $symbols" >> $GDBINIT
    echo "target remote :$po" >> $GDBINIT
    echo "tui enable" >> $GDBINIT
    echo "end" >> $GDBINIT
    echo "document $cmd" >> $GDBINIT
    echo "Print gdb init set." >> $GDBINIT
    echo "end" >> $GDBINIT
}

function do_pre_connect()
{
    po="$1"
    dest="$2"
    
    ret=`adb root`
    if [ "y$ret" == "y" ]; then
        echo_red "ADB ROOT失败！"
        exit 1
    fi

    adb push $GDB_server $GDB_SERVER_PATH && adb shell chmod +x $GDB_SERVER_PATH
    echo_green "启动 gdbserver: adb shell $GDB_SERVER_PATH :$po $dest &"
    adb shell $GDB_SERVER_PATH :$po $dest &
    echo_green "TCP转发: adb forward tcp:$po tcp:$po"
    adb forward tcp:$po tcp:$po
}

function get_execfile_name()
{
    path="$1"
    execdest="${path#*system}"
    if [ "y$execdest" == "y$path" ]; then
        execdest="${path#*vendor}"
        if [ "y$execdest" == "y$path" ]; then
            echo_red "not found dest:$path"
            exit 0
        else
            execdest="vendor$execdest"
        fi
    else
        execdest="system$execdest"
    fi
}

function get_so_path()
{
    syms=$1
    j=""
    search_lib_p=""
    
    syms=${syms/%\//''}
    search_lib=`find $syms -name *.so`
   
    rm -rf ~/.slib
    for i in $search_lib ; do
        k=${i%/*}
        echo $k >> ~/.slib
    done
    
    search_lib_p=`sort -u ~/.slib`
    for i in $search_lib_p ; do
        j+="$PWD/$i:"
    done;

    symbols_search_path=${j/%\:/''}
}

function usage_print()
{
    echo "----------------------------------------------[使用说明]--------------------------------------------------"
    echo "gdb & gdbserver 需要用NDK里面的!!!"
    echo "./gdb-debug.sh [符号目录] [可执行程序名称]"
    echo_green "./gdb-debug.sh out/target/product/v830/symbols vendor.tinno.hardware.FactoryServer@1.0-service"
    echo "----------------------------------------------------------------------------------------------------------"
}

####################################【我是分割线】########################################
symbols="$1"
execfile="$2"

#symbols=out/target/product/v830/symbols
#execfile=vendor.tinno.hardware.FactoryServer@1.0-service

if [ "y$execfile" = "y" ] || [ "y$symbols" = "y" ] ; then
    usage_print;
    exit 0;
fi

GDBTMP=~/.gdbtmp
echo "symbols=$symbols" > $GDBTMP
echo "execfile=$execfile" >> $GDBTMP

NDK=/home/android/Android/android-ndk-r20
GDB=$NDK/prebuilt/linux-x86_64/bin/gdb
GDB_SERVER=$NDK/prebuilt/android-arm/gdbserver/gdbserver
GDB_SERVER64=$NDK/prebuilt/android-arm64/gdbserver/gdbserver
GDB_SERVER_PATH=/data/gdbserver
GDB_server=$GDB_SERVER
GDBINIT=~/.gdbinit
port=1235
execdest=""
symbols_search_path=""

if [ ! -d $symbols ]; then
    echo_red "符号目录输入错误: $symbols"
    exit 0;
fi

get_so_path $symbols
if [ "y$symbols_search_path" = "y" ]; then
    echo_red "获取symbols目录失败！"
    exit 0;
fi
echo_green "获取依赖so目录集合..ok".

execfile_path=`find $symbols -name $execfile`
if [ "y$execfile_path" = "y" ]; then
    echo_red "可执行程序输入错误: $execfile"
    exit 0;
fi

get_execfile_name $execfile_path
echo_green "获取可执行程序路径..ok".

echo_green "准备调试..".
reset_port $port
do_pre_connect $port $execdest

echo_green "GDB初始化命令: go [设置依赖so路径 启动tui 连接到远程服务..]"
create_gdbinit_cmd "go" $symbols_search_path $port

echo_green "启动GDB调试客户端: $GDB $execfile_path"
$GDB $execfile_path



