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

function echo_yellow()
{
    echo -e "\e[1;33m$*\e[0m"
}

function echo_blue()
{
    echo -e "\e[1;34m$*\e[0m"
}

echo_yellow '
############################################################
#
# Android GDB & GDBSERVER DEBUG SCRIPT.
# GUO MINGYI 20191106
#
############################################################
'

function usage_print()
{
    echo "----------------------------------------------[使用说明]--------------------------------------------------"
    echo "!!! gdb, gdbserver 需要用NDK里面的 !!!"
    echo "./gdb-debug.sh --ndk=[ndk目录] --e=[可执行程序名称] --s=[符号表路径] --arch=[体系架构:arm32/arm64] --attach=[调试模式:yes/no] --p=[端口，默认1234]"
    echo_green "./gdb-debug.sh --ndk=/home/android/Android/android-ndk-r20 --e=vendor.tinno.hardware.FactoryServer@1.0-service --s=out/target/product/v830/symbols --arch=arm32 --attach=no --p=1235"
    echo "----------------------------------------------------------------------------------------------------------"
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
    port="$3"
    echo "define $cmd" > $GDBINIT
    echo "set solib-search-path $ssp" >> $GDBINIT
    echo "set solib-absolute-prefix $symbols" >> $GDBINIT
    echo "target remote :$port" >> $GDBINIT
    echo "tui enable" >> $GDBINIT
    echo "end" >> $GDBINIT
    echo "document $cmd" >> $GDBINIT
    echo "Print gdb init set." >> $GDBINIT
    echo "end" >> $GDBINIT
}

function do_start_gdbserver_connect()
{
    port="$1"
    dest="$2"

    ret=`adb root`
    if [ "y$ret" == "y" ]; then
        echo_red "ADB ROOT失败！"
        exit 1
    fi

    echo_green "关闭 SELINUX POLICY"
    adb shell setenforce 0
    adb push $GDB_server $GDB_SERVER_PATH && adb shell chmod +x $GDB_SERVER_PATH

    if [ "y$GDB_ATTACH" = "yyes" ]; then
        pid=`adb shell ps -e |grep $execfile |awk '{print $2}'`
        echo_green "adb shell $GDB_SERVER_PATH :$port --attach $pid &"
        if [ ! "y$pid" = "y" ]; then
            adb shell $GDB_SERVER_PATH :$port --attach $pid &
            echo "....going....."
        else
            echo_red "Cannot find process: $execfile"
        fi
    else
        echo_green "adb shell $GDB_SERVER_PATH :$port $dest &"
        adb shell $GDB_SERVER_PATH :$port $dest &
    fi

    echo_green "adb forward tcp:$port tcp:$port"
    adb forward tcp:$port tcp:$port
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

# 解析输入参数命令.
function swich_to_parse()
{
    args="$1"
    ret=${args#*=}

    if [[ "y$args" =~ "y--ndk=" ]]; then
        NDK=$ret
        sed -i '/\--ndk=/d' $GDBACTION
    fi

    if [[ "y$args" =~ "y--e=" ]]; then
        execfile=$ret
        sed -i '/\--e=/d' $GDBACTION
    fi

    if [[ "y$args" =~ "y--s=" ]]; then
        symbols=$ret
        sed -i '/\--s=/d' $GDBACTION
    fi

    if [[ "y$args" =~ "y--arch=" ]]; then
        ARCH=$ret
        sed -i '/\--arch=/d' $GDBACTION
    fi

    if [[ "y$args" =~ "y--attach=" ]]; then
        GDB_ATTACH=$ret
        sed -i '/\--attach=/d' $GDBACTION
    fi

    if [[ "y$args" =~ "y--p=" ]]; then
        GDB_PORT=$ret
        sed -i '/\--p=/d' $GDBACTION
    fi

    echo $args >> $GDBACTION
}

function read_cfg_from_tmpfile()
{
    if [ "y$NDK" = "y" ]; then
        args=`cat $GDBACTION |grep "\--ndk="`
        if [ ! "y$args" = "y" ]; then
            NDK=${args#*=}
        fi
    fi

    if [ "y$execfile" = "y" ]; then
        args=`cat $GDBACTION |grep "\--e="`
        if [ ! "y$args" = "y" ]; then
            execfile=${args#*=}
        fi
    fi

    if [ "y$symbols" = "y" ]; then
        args=`cat $GDBACTION |grep "\--s="`
        if [ ! "y$args" = "y" ]; then
            symbols=${args#*=}
        fi
    fi

    if [ "y$ARCH" = "y" ]; then
        args=`cat $GDBACTION |grep "\--arch="`
        if [ ! "y$args" = "y" ]; then
            ARCH=${args#*=}
        fi
    fi

    if [ "y$GDB_ATTACH" = "y" ]; then
        args=`cat $GDBACTION |grep "\--attach="`
        if [ ! "y$args" = "y" ]; then
            GDB_ATTACH=${args#*=}
        fi
    fi

    if [ "y$GDB_PORT" = "y1235" ]; then
        args=`cat $GDBACTION |grep "\--p="`
        if [ ! "y$args" = "y" ]; then
            GDB_PORT=${args#*=}
        fi
    fi
}

function main_enter()
{
    for i in $actionx ; do
        swich_to_parse $i
    done

    read_cfg_from_tmpfile

    GDB=$NDK/prebuilt/linux-x86_64/bin/gdb
    GDB_SERVER=$NDK/prebuilt/android-arm/gdbserver/gdbserver
    GDB_SERVER64=$NDK/prebuilt/android-arm64/gdbserver/gdbserver
    GDB_SERVER_PATH=/data/gdbserver

    if [ "y$ARCH" = "yarm64" ]; then
        GDB_server=$GDB_SERVER64
    else
        GDB_server=$GDB_SERVER
    fi

    echo "------------------------------------------------------------------------"
    echo_blue "GDB:          $GDB"
    echo_blue "GDBSERVER:    $GDB_server"
    echo_blue "ARCH:         $ARCH"
    echo_blue "GDB_ATTACH:   $GDB_ATTACH"
    echo_blue "PORT:         $GDB_PORT"
    echo_blue "SYMBOLS:      $symbols"
    echo_blue "EXECULABLE:   $execfile"
    echo "------------------------------------------------------------------------"

    if [ "y$execfile" = "y" ] || [ "y$symbols" = "y" ] || [ "y$NDK" = "y" ]; then
        usage_print;
        echo_red "输入参数错误!"
    fi

    if [ ! -e $GDB ]; then
        echo_red "GDB路径错误: $GDB"
    fi

    if [ ! -d $symbols ]; then
        echo_red "符号目录输入错误: $symbols"
    fi

    get_so_path $symbols
    if [ "y$symbols_search_path" = "y" ]; then
        echo_red "获取symbols目录失败！"
    fi
    echo_green "获取依赖so目录集合..ok".

    execfile_path=`find $symbols -name $execfile`
    if [ "y$execfile_path" = "y" ]; then
        echo_red "可执行程序输入错误: $execfile"
    fi

    get_execfile_name $execfile_path
    echo_green "获取可执行程序路径..ok".

    echo_green "准备调试..".
    reset_port $GDB_PORT
    do_start_gdbserver_connect $GDB_PORT $execdest

    echo_green "GDB初始化命令: go [设置依赖so路径启动tui连接到远程服务..]"
    create_gdbinit_cmd "go" $symbols_search_path $GDB_PORT

    echo_green "启动GDB调试客户端: $GDB $execfile_path"
    $GDB $execfile_path
}

####################################【我是分割线】########################################

actionx="$@"
# symbols=out/target/product/v830/symbols
# execfile=vendor.tinno.hardware.FactoryServer@1.0-service

ARCH=arm32
GDB_ATTACH=""
NDK=/home/android/Android/android-ndk-r20
GDB=""
GDB_SERVER=""
GDB_SERVER64=""
GDB_server=""
GDB_SERVER_PATH=/data/gdbserver
GDB_server=""
GDBINIT=~/.gdbinit
GDBACTION=~/.gdbtmp
GDB_PORT=1235
execdest=""
symbols_search_path=""

main_enter
