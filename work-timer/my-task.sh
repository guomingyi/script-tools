#!/bin/bash
# 

#adb shell rm -r sdcard/mtklog

echo "It time to start monkey test .."

adb shell monkey --throttle 1000 -s 1 --pct-trackball 0 --ignore-security-exceptions --ignore-crashes --ignore-timeouts --ignore-native-crashes -v 200000000 2>&1 | tee /home/android/log/monkey-test/4661/monkey-test.log


echo "end monkey test .."

adb pull sdcard/mtklog /home/android/log/monkey-test/4661/mtklog
