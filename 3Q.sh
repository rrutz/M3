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
		RELEASE=DEV
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
		echo error: DEV link does not exist for "$MPRdev""$META"/"$PROJECT" >&2
		exit 1
	fi

	if [[ "$RELEASENAME" == `readlink "$MPRdist""$META"/"$PROJECT"/UAT` ]]
	then
		echo UAT already linked to the most recent DEV release
		exit 1
	fi
}

function printSuccess
{
	echo Command successfuly completed
	echo '############################################################'
}


function createCheckpoint
{ 
	echo Running command: efs checkpoint "$META" "$PROJECT" "$RELEASENAME"
	efs checkpoint "$META" "$PROJECT" "$RELEASENAME" > /dev/null
	PATH1="$MPRdev""$META"/"$PROJECT"/"$RELEASENAME"

	OWNER=`ls -ld "$PATH1" | awk '{ print $3 }'`
	if [[ "$OWNER" != "root" ]]
	then
		echo error: Unable to change owner of "$PATH1" to root >&2
		exit 1
	fi
		
	GROUP=`ls -ld "$PATH1" | awk '{ print $4 }'`
	if [[ "$GROUP" != "root" ]]
	then
		echo error: Unable to change group of "$PATH1" to root >&2
		exit 1
	fi
	
	printSuccess
}

function distRelease
{
	MPRdist=/efs/dist/"$META"/"$PROJECT"/"$RELEASENAME"
	if [[ ! -d "$MPRdist" ]]
	then
		echo Running command: efs dist release "$META" "$PROJECT" "$RELEASENAME"
		efs dist release "$META" "$PROJECT" "$RELEASENAME" > /dev/null
		if [ ! -d "$MPRdist" ]
                then
                        echo error: unable to make $MPRdist >&2
                        exit 1
                fi  
	else
		echo error: $MPRdist already exists >&2
		exit 1
	fi
	printSuccess
}

function createReleaseLink
{
	echo Running command: create releaselink "$META" "$PROJECT" "$RELEASENAME" UAT
	efs create releaselink "$META" "$PROJECT" "$RELEASENAME" UAT > /dev/null
	if [[ `readlink "$MPRdev""$META"/"$PROJECT"/UAT` != "$RELEASENAME" ]]
	then
		echo error: Unable to create UAT link >&2
		exit 1
	fi
	printSuccess
}

function DistIt
{
	echo Running command: efs dist releaselink $META $PROJECT UAT 
	# error checking for copying????
	efs dist releaselink $META $PROJECT UAT  > /dev/null
	printSuccess
}

function main
{
	echo '############################################################'
	inputValidation $@
	createCheckpoint
	distRelease
	createReleaseLink
	DistIt	
	exit 0
}

main $@