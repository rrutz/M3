#!/bin/bash
function Q1
{
	if [[ $# -ne 1 ]]
	then
		echo usage: $0 VersionName >&2
		exit 1
	fi

	NUM=`echo $1 | awk -F"_" '{print $NF}'`
	USERNAME=`echo $1 | awk -F"_" 'BEGIN {OFS = FS} {$NF=""; print}'`
	USERNAME=`echo -e $USERNAME`

	if [[ "$NUM" =~ [0-9]+$ ]] && [[ "$USERNAME" != "" ]]
	then
		NEW_FILE_PATH="$USERNAME"`expr $NUM + 1`
	else
		NEW_FILE_PATH=""$1"_1"
	fi

	echo $NEW_FILE_PATH
	exit 0
}

Q1 $@
