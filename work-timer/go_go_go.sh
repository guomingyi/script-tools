#!/bin/bash
#
# 1 > ./go_go_go.sh 
# 2 > ./go_go_go.sh -d 
#
# default config.
#
# ./work_timerd  -d  -p prj-name  -b build-type  -r prj-path  -t timer-set &
#

#./work_timerd $1 -p v3991 -b user -r /home/android/driver/work/6737-master/ -t 21:00 &
sleep 1

./work_timerd $1 -p v3991 -b userdebug -r /home/android/driver/work/6737-develop -t 20:00 &
sleep 1

#./work_timerd $1 -p p7701 -b user -r /home/android/driver/work/7701 -t 04:30 &
sleep 1

#./work_timerd $1 -p p7705 -b user -r /home/android/driver/work/7705 -t 06:00 &
#sleep 1


ps -ef |grep work_timerd
