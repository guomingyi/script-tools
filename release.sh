#!/bin/bash
set -e


TARGET_PROJECT=`cat build.ini |grep ^ro.target |cut -d "=" -f 2 |tr -d ' '`
PROJECT_NAME=`cat build.ini |grep ^ro.project |cut -d "=" -f 2 |tr -d ' '`

target_name=$TARGET_PROJECT

#prj_info=`cat build.ini`
#index=`expr index "$prj_info" _`
#target_name=${prj_info:0:index-1}
#target_name=s4710 

show_help()
{
printf "
NAME
    打包软件

SYNOPSIS
    release.sh  [-r project] 

OPTIONS
    -r [project]  tags your project name



Examples:
    release.sh -r 's4710'
"
}


while getopts h:r: OPTION
do
	case $OPTION in
	h) show_help
	exit 0
	;;
	r) target_name=$OPTARG
	;;
	*) show_help
	exit 1
	;;
esac
done





if [ ! -d out/target/product/$target_name ] ; then
	echo "--------->>>>>NOT FOUND out/target/prodect/$target_name/ path!---------------------,exit(1)"
	exit 1
fi


if [ -e out/target/product/$target_name/system/build.prop ] ; then
version=`cat out/target/product/$target_name/system/build.prop |grep ^ro.internal.build.version |cut -d "=" -f 2 |tr -d ' '`
type=`cat out/target/product/$target_name/system/build.prop |grep ^ro.build.type |cut -d "=" -f 2 |tr -d ' '`
user=`cat out/target/product/$target_name/system/build.prop |grep ^ro.build.user |cut -d "=" -f 2 |tr -d ' '`
modem_name=`cat device/tinno/$target_name/ProjectConfig.mk |grep ^CUSTOM_MODEM |cut -d "=" -f 2 |tr -d ' '`
echo "[PROJECT_NAME]: $PROJECT_NAME  [TARGET_PROJECT]: $target_name" "[version]: $version   [build type]: $type    [user]: $user" 

else

echo "release fail: out/target/product/$target_name/system/build.prop not found!"
exit 1

fi

#exit(1)

ota=_OTA
flasher=_FLASHER
result_ota=1
result_flasher=1
version2=$version


if [ -e out/target/product/$target_name/$target_name-ota*.zip ] ; then
	echo "Start to copy : $target_name-ota*.zip ..."
	cp out/target/product/$target_name/$target_name-ota*.zip 	$version2$ota.zip
else
result_ota=0
fi


version=$version$flasher

rm -rf $version
mkdir -p $version

echo "Start copy *img ..."

#COPY *.img ...
#cp out/target/product/$target_name/tee1 				$version
if [ -e out/target/product/$target_name/trustzone.bin ] ; then
cp out/target/product/$target_name/trustzone.bin 			$version
fi

cp out/target/product/$target_name/cache.img 				$version
cp out/target/product/$target_name/MT6*.txt 				$version
cp out/target/product/$target_name/lk.bin 				$version
cp out/target/product/$target_name/logo.bin 				$version
cp out/target/product/$target_name/preloader_$target_name.bin 		$version
cp out/target/product/$target_name/boot.img  				$version
cp out/target/product/$target_name/recovery.img 			$version
cp out/target/product/$target_name/secro.img 				$version
cp out/target/product/$target_name/system.img 				$version
cp out/target/product/$target_name/userdata.img 			$version

echo "Start copy db files ..."

#COPY AP && DB
if [ ! -d $version/db ] ; then
	mkdir -p $version/db
fi
cp out/target/product/$target_name/obj/CGEN/AP* 					$version/db


#cp out/target/product/$target_name/system/etc/mddb/BPLGUInfoCustomAppSrcP_* 				$version/db

#cp vendor/mediatek/proprietary/custom/$target_name/modem/$modem_name/BPLGUInfoCustomAppSrcP_*		$version/db

SW_PACK=sw_release
dest=~/$SW_PACK/$target_name-$PROJECT_NAME-$type

#MAKE ZIP.
echo "Start to make tar : $dest/$version.tar ..."
#zip -r $version.zip $version
tar -cvf $version.tar $version
rm -rf $version


if [ ! -d $dest ] ; then
   mkdir -p $dest
fi

mv $version.tar $dest

if [ $result_ota == 1 ] ; then
    mv $version2$ota.tar $dest
    echo "OUT------->> $dest/$version2$ota.tar"
fi

echo "OUT------->> $dest/$version.tar"









