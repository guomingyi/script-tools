#! /bin/bash

echo ""
echo "Start ramdump parser.."

local_path=$PWD
ramdump=$local_path/
vmlinux=$local_path/vmlinux
out=$local_path/out

gdb=~/tools/gnu-tools/aarch64-linux-android-4.9/bin/aarch64-linux-android-gdb
nm=~/tools/gnu-tools/aarch64-linux-android-4.9/bin/aarch64-linux-android-nm
objdump=~/tools/gnu-tools/aarch64-linux-android-4.9/bin/aarch64-linux-android-objdump

# git clone git://codeaurora.org/quic/la/platform/vendor/qcom-opensource/tools
ramparse_dir=~/tools/ramdump/tools/linux-ramdump-parser-v2
#ramparse_dir=/home/android/work/prj/6901-7.1/LA.UM.5.6/LINUX/android/vendor/qcom/opensource/tools/linux-ramdump-parser-v2
########################################################################################

echo "cd $ramparse_dir"
cd $ramparse_dir
echo ""

echo -e "python ramparse.py -v $vmlinux -g $gdb  -n $nm  -j $objdump -a $ramdump -o $out -x"
echo ""

# python 2.7.5
python ramparse.py -v $vmlinux -g $gdb  -n $nm  -j $objdump -a $ramdump -o $out -x --force-hardware 8937 --64-bit

cd $local_path
echo "out: $out"
echo ""
exit 0

















