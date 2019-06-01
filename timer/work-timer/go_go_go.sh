#!/bin/bash
#
# 1 > ./go_go_go.sh 
# 2 > ./go_go_go.sh -d 
#
# default config.
# -d : run background as daemon
#
# ./work_timerd  -d  -t time
#

./work_timerd $1 -t 22:40
sleep 1

ps -ef |grep work_timerd
