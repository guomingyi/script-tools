#!/bin/bash


#!/bin/bash
set -e
set -x

export ANDROID_NDK=/home/mingyi/Android/android-ndk-r21
export OPENSSL_DIR=/home/mingyi/github/openssl/build/openssl-1.1.1a
export toolchains_path=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64
export PATH=$toolchains_path/bin:$PATH
ANDROID_API=26
CC=clang
cd ${OPENSSL_DIR}
rm -rf output

# ndk version MUST >= r20, use clang to compile.
function start_build()
{
	./Configure ${ARCH_NAME} -D__ANDROID_API__=$ANDROID_API
	make clean
	make
	
	if [ ! $? == 0 ]; then
		echo "build error";
		exit 1
	fi
	
	# Copy the outputs
	OUTPUT_INCLUDE=$OPENSSL_DIR/output/include
	OUTPUT_LIB=$OPENSSL_DIR/output/lib/${ARCH}
	mkdir -p $OUTPUT_INCLUDE
	mkdir -p $OUTPUT_LIB
	cp -RL include/openssl $OUTPUT_INCLUDE
	cp libcrypto.so $OUTPUT_LIB
	cp libcrypto.a $OUTPUT_LIB
	cp libssl.so $OUTPUT_LIB
	cp libssl.a $OUTPUT_LIB
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
