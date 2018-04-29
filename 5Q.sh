#!/bin/bash
function inputValidation
{  
	if [[ $# -ne 2 ]] || [ $1 == "" ] || [ $2 == "" ] 
	then
		echo error message and usage
		exit 1
	else
		META=$1
		PROJECT=$2
		MPRdev="/efs/dev/"
	fi
	
	if [ ! -f "$MPRdev"efs ]
	then
		echo error: efs command does not exists
		exit 1
	fi  

	if [ ! -f "$MPRdev"efsusage ]
	then
		echo error: efsusage command does not exists
		exit 1
	fi  	
}

function getCurrentRelease
{
	LARGEST_NUM=0
	for FILE in `ls "$MPRdev""$META"/"$PROJECT" | grep "$USER"` 
	do
		NUM=`echo $FILE  | awk -F"_" '{print $NF}'`
 	
		if [[ $NUM -gt largestNum  ]]
		then	
			LARGEST_NUM=$NUM
        	fi
	done
	
	
	if [[ "$LARGEST_NUM" =~ [0-9]+$ ]] && [[ "$LARGEST_NUM" != 0 ]]
	then
		RELEASE=""$USER"_"$LARGEST_NUM""
	else
		echo Release does not exists
		exit 1
	fi
}


function creteReleseeLink
{
	echo Creating Release Link for $RELEASE
	efs create releaselink $META $PROJECT $RELEASE PROD
	if [[ `readlink "$MPRdev""$META"/"$PROJECT"/PROD` != "$RELEASE" ]]
	then
		echo Unable to create link
		exit 1
	fi
}

function DistIt
{
	# error check
	efs dist releaselink $META $PROJECT PROD
}

function main
{
	inputValidation $@
	getCurrentRelease
	creteReleseeLink
	DistIt	
	exit 0
}

main $@