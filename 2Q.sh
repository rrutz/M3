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
		MPRdev="/efs/dev/"
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
}

function printSuccess
{
	echo Command successfuly completed
	echo '############################################################'
}

function createDIR
{
        local EPS_COMMAND=$1
        local DIR=$2	
        if [[ ! -d "$DIR" ]]
        then
		echo Running command: $EPS_COMMAND
                $EPS_COMMAND 
                if [[ ! -d "$DIR" ]]
                then
                        echo error: unable to make "$DIR" >&2
                        exit 1
                fi     
		printSuccess
        fi
}

function nextReleaseName
{
	LARGEST_NUM=0
	for FILE in `ls "$MPRdev""$META"/"$PROJECT" | grep "$USER"` 
	do
		NUM=`echo $FILE | awk -F"_" '{print $NF}'`
 	
		if [[ $NUM -gt largestNum ]]
		then	
			LARGEST_NUM=$NUM
        	fi
	done

	if [[ "$LARGEST_NUM" =~ [0-9]+$ ]] && [[ "$LARGEST_NUM" != 0 ]]
	then
		RELEASE=""$USER"_"`expr $LARGEST_NUM + 1`""
	else
		RELEASE=""$USER""_1""
	fi
}

function createRelease
{
	echo Running command: efs create release $META $PROJECT $RELEASE
        nextReleaseName
        MPRrel="$MPRdev""$META"/"$PROJECT"/"$RELEASE"
        if [[ ! -d "$MPRrel" ]]
        then
                efs create release "$META" "$PROJECT" "$RELEASE" > /dev/null
                for FOLDER in "$MPRrel" "$MPRrel/src" "$MPRrel/install"
                do
                        if [[ ! -d "$FOLDER" ]]  
                        then
                                echo error: unable to make "$FOLDER" >&2
                                exit 1
                        fi
                done
        else
                echo error "$MPRrel" already exists >&2
                exit 1
        fi
	printSuccess
}

function clone 
{	
	git clone https://MthreeDelegate:AlumniTrain%40M3%2FT1@bitbucket.org/mthree_consulting/javademos.git ""$MPRrel"/src"
	if [[ $? != 0 ]] 
	then
		echo error: Unable to clone to "$MPRrel"/src >&2
		exit 1
	fi	
	printSuccess
}

function createCommon
{
	echo Running command: efs create install $META $PROJECT $RELEASE common 
    
        COMMON="$MPRdev""$META"/"$PROJECT"/"$RELEASE"/install/common
        if [[ ! -d "$COMMON" ]]
        then
                efs create install "$META" "$PROJECT" "$RELEASE" common > /dev/null
                if [[ ! -d "$COMMON" ]]
                then
                	echo error: unable to make "$COMMON" >&2
                        exit 1
                fi
        else
                echo error: "$COMMON" already exists >&2
                exit 1
        fi
	printSuccess
}

function copyToCommon
{
	echo Copying src context to common
	cp -R "$MPRdev""$META"/"$PROJECT"/"$RELEASE"/src "$MPRdev""$META"/"$PROJECT"/"$RELEASE"/install/common
	if [[ $? != 0 ]]
	then
		echo error: Unable to copy from src to common >&2
		exit 1
	fi
	printSuccess
}

function createDevReleaseLink
{
	echo Running command: efs create releaselink "$META" "$PROJECT" "$RELEASE" DEV
	efs create releaselink "$META" "$PROJECT" "$RELEASE" DEV > /dev/null
	if [[ `readlink "$MPRdev""$META"/"$PROJECT"/DEV` != "$RELEASE" ]]
	then
		echo error: Unable to create DEV link >&2
		exit 1
	fi
	printSuccess
}


function main
{
	echo '############################################################'
	inputValidation $@
	createDIR "efs create meta $META" ""$MPRdev""$META""
	createDIR "efs create project $META $PROJECT" ""$MPRdev"$META"/"$PROJECT"
	createRelease
	clone
	createCommon
	copyToCommon
	createDevReleaseLink
	
	exit 0
}

main $@

 
