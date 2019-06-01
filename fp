#!/bin/bash
#set -e

remote="tinno"

MESSAGE=""

show_help()
{
printf "
NAME
    自动提交脚本

SYNOPSIS
    cm.sh [-h] | [-t tags]  [-m commit log] 

OPTIONS
    -h             Display help message
    -t [tags]  tags your want to commit
 
    -m [message]    commit log


Examples:
    cm.sh -t S9081-IN-MMX-V1.0 -m 'commit log'
"
}

while getopts h:t:m: OPTION
do
	case $OPTION in
	h) show_help
	exit 0
	;;
	t) TAGS=$OPTARG
	;;
	m) MESSAGE=$OPTARG
	;;
	*) show_help
	exit 1
	;;
esac
done


git add .
git branch -D work;
git checkout -b work
git commit -am "$MESSAGE"
repo sync .     
git cherry-pick work
git push $remote HEAD:master

echo "------------------>push done------------------------!"






