function inputValidation
{
	if [[ $# -ne 3 ]] || [ $1 == "" ] || [ $2 == "" ] || [ $3 == "" ]
	then
			echo error message and usage
			exit 1
	else
			FILE_NAME=$1 
			META=$2 
			PROJECT=$3
			MPRdev="/efs/dev/"
	fi
	
	if [ ! -f "$MPRdev"efs ]
	then
			echo error: efs command does not exists
			exit 1
	fi  

	if [ ! -f "$MPRdev$"efsusage ]
	then
			echo error: efsusage command does not exists
			exit 1
	fi  	
}

function createDIR
{
        local EPS_COMMAND=$1
        local DIR=$2

        if [ ! -d "$DIR" ]
        then
				echo \###### Running command: $EPS_COMMAND
                $EPS_COMMAND 
                if [ ! -d "$DIR" ]
                then
                        echo error: unable to make meta > &3
                        exit 1
                fi     
				echo \###################################################
        fi
}

function nextReleaseName
{
        local NUM=`echo $FILE_NAME | awk -F"_" '{print $NF}'`
        local USERNAME=`echo $FILE_NAME | awk -F"_" 'BEGIN {OFS = FS} {$NF=""; print}'`
        local USERNAME=`echo -e $USERNAME`
 
        if [[ "$NUM" =~ [0-9]+$ ]] && [[ "$USERNAME" != "" ]]
        then
                RELEASE=""$USERNAME""`expr $NUM + 1`""
        else
                RELEASE=""$FILE_NAME""_1""
        fi
}

function createRelease
{
        nextReleaseName
        MPRdev=/efs/dev/$META/$PROJECT/$RELEASE
        if [ ! -d "MPRdev" ]
        then
                efs create release $META $PROJECT $RELEASE
                for FOLDER in "MPRdev/" "MPRdev/src/" "MPRdev/install/"
                do
                        if [ ! -d "$FOLDER" ]  
                        then
                                echo error: unable to make "$FOLDER"
                                exit 1
                        fi
                done
        else
                echo $MPRdev already exists
                exit 1
        fi
}

function clone 
{
	# error check
	git clone https://MthreeDelegate:AlumniTrain%40M3%2FT1@bitbucket.org/mthree_consulting/javademos.git ""$DIRECTORY""$RELEASE"/src/"
}

function createCommon
{
	# error check
	efs create install $META $PROJECT $RELEASE common
}

function createLink
{
	# error check
	efs create releaselink $META $PROJECT $RELEASE DEV
	efs dist releaselink $META $PROJECT DEV
}

function main
{
	inputValidation
	
	createDIR "efs create meta $META" ""$MPRdev""$META""
	createDIR "efs create project $META $PROJECT" ""$MPRdev"$META""$PROJECT"
	createRelease
	clone
	createCommon
	createLink
	
	exit 0
}

main

 