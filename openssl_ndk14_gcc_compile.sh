#!/bin/bash


func_cmp(){
	cd /home/mingyi/github/openssl/build/openssl-1.1.1a
	make clean
	rm -rf ./output-$ARCH
	mkdir ./output-$ARCH
	export ANDROID_NDK=/home/mingyi/tools/android-ndk-r14b
	export PATH=$ANDROID_NDK/toolchains/$TOOL_CHAIN/prebuilt/linux-x86_64/bin:$PATH
	./Configure $ARCH_NAME -D__ANDROID_API__=23 --prefix=/home/mingyi/github/openssl/build/openssl-1.1.1a/output-$ARCH
	make
}
 
for ARCH in armeabi-v7a armeabi arm64-v8a
do
	echo $ARCH
	if [ "$ARCH" = "armeabi-v7a" ]; then
		ARCH_NAME=android-arm
		TOOL_CHAIN=arm-linux-androideabi-4.9
	fi
	if [ "$ARCH" = "armeabi" ]; then
		ARCH_NAME=android-arm
		TOOL_CHAIN=arm-linux-androideabi-4.9
	fi
	if [ "$ARCH" = "arm64-v8a" ]; then
		ARCH_NAME=android-arm64
		TOOL_CHAIN=aarch64-linux-android-4.9
	fi
	if [ "$ARCH" = "mips" ]; then
		ARCH_NAME=android-mips
		TOOL_CHAIN=mipsel-linux-android-4.9
	fi
	if [ "$ARCH" = "mips64" ]; then
		ARCH_NAME=android-mips64
		TOOL_CHAIN=mips64el-linux-android-4.9
	fi
	if [ "$ARCH" = "x86" ]; then
		ARCH_NAME=android-x86
		TOOL_CHAIN=x86-4.9
	fi
	if [ "$ARCH" = "x86_64" ]; then
		ARCH_NAME=android-x86_64
		TOOL_CHAIN=x86_64-4.9
	fi
	echo $TOOL_CHAIN
	func_cmp
done

