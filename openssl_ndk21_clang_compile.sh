#!/bin/bash


#!/bin/bash
set -e
set -x

# ndk version MUST >= r20, use clang to compile.
function start_build()
{
	export ANDROID_NDK=/home/mingyi/Android/android-ndk-r21
	OPENSSL_DIR=/home/mingyi/github/openssl/build/openssl-1.1.1a
	toolchains_path=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64
	PATH=$toolchains_path/bin:$PATH
	ANDROID_API=26
	CC=clang

	cd ${OPENSSL_DIR}
	make clean
	rm -rf ./output-$ARCH
	mkdir ./output-$ARCH -p

	./Configure ${ARCH_NAME} -D__ANDROID_API__=$ANDROID_API --prefix=$OPENSSL_DIR/output-$ARCH
	make

}

# Can be android-arm, android-arm64, android-x86, android-x86 etc
for ARCH in armeabi-v7a arm64-v8a; do
	echo $ARCH
	if [ "$ARCH" = "armeabi-v7a" ]; then
		ARCH_NAME=android-arm
	fi
	
	if [ "$ARCH" = "arm64-v8a" ]; then
		ARCH_NAME=android-arm64
	fi

	start_build
done
