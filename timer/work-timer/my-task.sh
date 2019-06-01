#!/bin/bash
#
# day build timer
#########################################################################


#########################################################################
build_prj=p7201
build_type=userdebug
prj_path=/home/android/work/prj/7201-7.1
#-------------------------------------------------------#
echo "start to build:$prj_path $build_prj $build_type"
cd $prj_path

echo "rm -rf all.."
rm -rf ./*

echo "repo sync.."
repo sync -j8;

echo "go to start build.."
cd ./release;

./days_build.sh $build_prj trunk $build_type

echo "package img.."
#./days_package1.sh $build_prj trunk
##################################

build_prj=p7201
build_type=userdebug
prj_path=/home/android/work/prj/7201-7.0
#-------------------------------------------------------#
echo "start to build:$prj_path $build_prj $build_type"
cd $prj_path

echo "rm -rf all.."
rm -rf ./*

echo "repo sync.."
repo sync -j8;

echo "go to start build.."
cd ./release;

./days_build.sh $build_prj trunk $build_type

echo "package img.."
#./days_package1.sh $build_prj trunk
##################################
build_prj=v3991
build_type=userdebug
prj_path=/home/android/work/prj/6737-7.0
#-------------------------------------------------------#
echo "start to build:$prj_path $build_prj $build_type"
cd $prj_path

echo "rm -rf all.."
rm -rf ./*

echo "repo sync.."
repo sync -j8;

echo "go to start build.."
cd ./release;

./days_build.sh $build_prj trunk $build_type

echo "package img.."
./days_package1.sh $build_prj trunk
##################################

echo "GOOOD BYE!"
exit 0;

