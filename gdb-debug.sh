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
    echo_green "./gdb-debug.sh 
    --ndk:[ndk目录] 
    --e:[可执行程序] 
    --s:[符号表路径] 
    --arch:[体系架构:arm32/arm64] 
    --attach:[调试模式:yes/no] 
    --p:[端口，默认1234] 
    --apk:[apk包名称,必须是attach模式调试]"

    echo "example:"
    echo "./gdb-debug.sh 
    --ndk:/home/android/Android/android-ndk-r20 
    --e:out/target/product/v830/symbols/vendor/bin/hw/vendor.tinno.hardware.FactoryServer@1.0-service 
    --s:out/target/product/v830/symbols 
    --arch:arm32 
    --attach:no"

    echo "./gdb-debug.sh 
    --e:out/target/product/k150/symbols/system/bin/app_process32 
    --s:/home/android/log/symbols
    --apk:com.alley.openssl "
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
    echo "symbols path=$ssp"

    echo "define $cmd" > $GDBINIT
    #  echo "set sysroot $symbols" >> $GDBINIT
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
    process=$execfileName

    ret=`adb root`
    if [ "y$ret" == "y" ]; then
        echo_red "ADB ROOT失败！"
        exit 1
    fi

    echo_green "关闭 SELINUX POLICY"
    adb shell setenforce 0
    adb push $GDB_server $GDB_SERVER_PATH && adb shell chmod +x $GDB_SERVER_PATH

    if [ ! "y$ApkProcess" = "y" ]; then
        process=$ApkProcess
    fi

    if [ "y$GDB_ATTACH" = "yyes" ]; then
        pid=`adb shell ps -e |grep $process |awk '{print $2}'`
        echo_green "adb shell $GDB_SERVER_PATH :$port --attach $pid &"
        if [ ! "y$pid" = "y" ]; then
            adb shell $GDB_SERVER_PATH :$port --attach $pid &
            echo "....going....."
        else
            echo_red "Cannot find process: $process"
        fi
    else
        echo_green "adb shell $GDB_SERVER_PATH :$port $dest &"
        adb shell $GDB_SERVER_PATH :$port $dest &
    fi

    echo_green "adb forward tcp:$port tcp:$port"
    adb forward tcp:$port tcp:$port
}

function get_execdest()
{
    execname="$1"
    search="/vendor/bin /system/bin"

    for i in $search ; do
        j=`adb shell find $i -name $execname`
        if [ ! "y$j" = "y" ]; then
            execdest=$j
            echo "$j"
            return;
        fi
    done

    echo_red "没有找到合适路径的可执行程序！"
}

function get_so_path()
{
    syms=$1
    j=""
    search_lib_p=""

    syms=${syms/%\//''}
    search_lib=`find $syms -name *.so`
    echo "search_lib=$search_lib"

    rm -rf ~/.slib
    for i in $search_lib ; do
        k=${i%/*}
        echo $k >> ~/.slib
    done

    search_lib_p=`sort -u ~/.slib`
    for i in $search_lib_p ; do
        j+="$i:"
    done;

    symbols_search_path=${j/%\:/''}
}

# 解析输入参数命令.
function swich_to_parse()
{
    args="$1"
    ret=${args#*:}

    if [[ "y$args" =~ "y--help" ]]; then
        usage_print;
        exit 0;
    fi

    # 判断后者是否被前者包含.
    if [[ "y$args" =~ "y$NDKPREFIX" ]]; then
        NDK=$ret
        sed -i "/\\$NDKPREFIX/d" $GDBACTION
    fi

    if [[ "y$args" =~ "y$EXECPERFIX" ]]; then
        execfile=$ret
        sed -i "/\\$EXECPERFIX/d" $GDBACTION
    fi

    if [[ "y$args" =~ "y$SYMBPERFIX" ]]; then
        symbols=$ret
        sed -i "/\\$SYMBPERFIX/d" $GDBACTION
    fi

    if [[ "y$args" =~ "y$ARCHPERFIX" ]]; then
        ARCH=$ret
        sed -i "/\\$ARCHPERFIX/d" $GDBACTION
    fi

    if [[ "y$args" =~ "y$ATTACHPERFIX" ]]; then
        GDB_ATTACH=$ret
        sed -i "/\\$ATTACHPERFIX/d" $GDBACTION
    fi

    if [[ "y$args" =~ "y$PORTPERFIX" ]]; then
        GDB_PORT=$ret
        sed -i "/\\$PORTPERFIX/d" $GDBACTION
    fi

    if [[ "y$args" =~ "y$APKPERFIX" ]]; then
        ApkProcess=$ret
        sed -i "/\\$APKPERFIX/d" $GDBACTION
    fi

    echo $args >> $GDBACTION
}

function read_cfg_from_tmpfile()
{
    ret=${args#*:}

    if [ "y$NDK" = "y" ]; then
        args=`cat $GDBACTION |grep "\\$NDKPREFIX"`
        if [ ! "y$args" = "y" ]; then
            NDK=$ret
        fi
    fi

    if [ "y$execfile" = "y" ]; then
        args=`cat $GDBACTION |grep "\\$EXECPERFIX"`
        if [ ! "y$args" = "y" ]; then
            execfile=$ret
        fi
    fi

    if [ "y$symbols" = "y" ]; then
        args=`cat $GDBACTION |grep "\\$SYMBPERFIX"`
        if [ ! "y$args" = "y" ]; then
            symbols=$ret
        fi
    fi

    if [ "y$ARCH" = "y" ]; then
        args=`cat $GDBACTION |grep "\\$ARCHPERFIX"`
        if [ ! "y$args" = "y" ]; then
            ARCH=$ret
        fi
    fi

    if [ "y$GDB_ATTACH" = "y" ]; then
        args=`cat $GDBACTION |grep "\\$ATTACHPERFIX"`
        if [ ! "y$args" = "y" ]; then
            GDB_ATTACH=$ret
        fi
    fi

    if [ "y$GDB_PORT" = "y1235" ]; then
        args=`cat $GDBACTION |grep "\\$PORTPERFIX"`
        if [ ! "y$args" = "y" ]; then
            GDB_PORT=$ret
        fi
    fi

    if [ "y$ApkProcess" = "y" ]; then
        args=`cat $GDBACTION |grep "\\$APKPERFIX"`
        if [ ! "y$args" = "y" ]; then
            ApkProcess=$ret
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

    if [ ! "y$ApkProcess" = "y" ]; then
        GDB_ATTACH=yes
    fi

    echo "------------------------------------------------------------------------"
    echo_blue "NDK:          $NDK"
    echo_blue "ARCH:         $ARCH"
    echo_blue "GDB_ATTACH:   $GDB_ATTACH"
    echo_blue "PORT:         $GDB_PORT"
    echo_blue "SYMBOLS:      $symbols"
    echo_blue "EXECULABLE:   $execfile"
    echo_blue "APK PROCESS:  $ApkProcess"
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

    execfileName=${execfile##*/}
    if [ "y$execfileName" = "y" ]; then
        echo_red "获取可执行程序名称失败！"
    fi

    get_execdest $execfileName
    echo_green "获取可执行程序路径..ok".

    echo_green "准备调试..".
    reset_port $GDB_PORT
    do_start_gdbserver_connect $GDB_PORT $execdest

    echo_green "GDB初始化命令: go [设置依赖so路径启动tui连接到远程服务..]"
    create_gdbinit_cmd "go" $symbols_search_path $GDB_PORT

    echo_green "$GDB $execfile"
    $GDB $execfile
}

####################################【我是分割线】########################################

actionx="$@"
# symbols=out/target/product/v830/symbols
execfile=out/target/product/v830/symbols/vendor/bin/hw/vendor.tinno.hardware.FactoryServer@1.0-service
symbols=""
execfileName=""

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
ApkProcess=""
app_process=""

NDKPREFIX="--ndk:"
EXECPERFIX="--e:"
SYMBPERFIX="--s:"
ARCHPERFIX="--arch:"
ATTACHPERFIX="--attach:"
PORTPERFIX="--p:"
APKPERFIX="--apk:"


# 主程序入口.
main_enter
