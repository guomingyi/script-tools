#!/bin/bash

args="$@"


adb wait-for-device;
adb logcat -c
for ((i=0; i<1000; i++)); do
	adb wait-for-device;
	adb root;
	adb wait-for-device;
	adb logcat 2>&1|tee ~/1.log
done



