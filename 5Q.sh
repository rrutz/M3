#!/bin/bash
function inputValidation
{  
	if [[ $# -ne 2 ]]
	then
		echo usage: $0 META PROJECT >&2
		exit 1
	else
		META=$1
		PROJECT=$2
		RELEASE=UAT
		MPRdev="/efs/dev/"
		MPRdist="/efs/dist/"
		RELEASENAME=`readlink "$MPRdev""$META"/"$PROJECT"/"$RELEASE"`
	fi
	
	if [[ ! -f "$MPRdev"efscmds ]]
	then
		echo error: "$MPRdev"efscmds does not exist >&2
		exit 1
	fi  	

	if [[ ! -f "$MPRdev"efs ]]
	then
		echo error: "$MPRdev"efs does not exist >&2
		exit 1
	fi  	

	if [[ `which efs` != "/efs/dev/efs" ]] 
	then
		echo error: Path to efs command is not "/efs/dev/efs" >&2
		exit 1
	fi

	if [[ `which efscmds` != "/efs/dev/efscmds" ]]
	then
		echo error: Path to efscmds command is not "/efs/dev/efscmds" >&2
		exit 1
	fi	
	
	readlink "$MPRdev""$META"/"$PROJECT"/"$RELEASE" > /dev/null
	if [[ $? != 0 ]]
	then 
		echo error: UAT link does not exist for "$MPRdev""$META"/"$PROJECT" >&2
		exit 1
	fi

	if [[ "$RELEASENAME" == `readlink "$MPRdist""$META"/"$PROJECT"/PROD` ]]
	then
		echo PROD already linked to the most recent UAT release
		exit 1
	fi
}

function printSuccess
{
	echo Command successfuly completed
	echo '############################################################'
}

function createReleaseLink
{
	echo Running command: create releaselink "$META" "$PROJECT" "$RELEASENAME" PROD
	efs create releaselink "$META" "$PROJECT" "$RELEASENAME" PROD > /dev/null
	if [[ `readlink "$MPRdev""$META"/"$PROJECT"/PROD` != "$RELEASENAME" ]]
	then
		echo error: Unable to create PROD link >&2
		exit 1
	fi
	printSuccess
}

function DistIt
{
	echo Running command: efs dist releaselink $META $PROJECT PROD 
	# error checking for copying????
	efs dist releaselink $META $PROJECT PROD  > /dev/null
	printSuccess
}

function main
{
	echo '############################################################'
	inputValidation $@
	createReleaseLink
	DistIt	
	exit 0
}

main $@