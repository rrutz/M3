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

function createDIR
{
        local EPS_COMMAND=$1
        local DIR=$2	
        if [ ! -d "$DIR" ]
        then
		echo '###### Running command: '$EPS_COMMAND
                $EPS_COMMAND 
                if [ ! -d "$DIR" ]
                then
                        echo error: unable to make folder 
                        exit 1
                fi     
		echo '###################################################'
        fi
}


function nextReleaseName
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
		RELEASE=""$USER"_"`expr $LARGEST_NUM + 1`""
	else
		RELEASE=""$USER""_1""
	fi
}

function createRelease
{
	echo '###### Running command: ' efs create release $META $PROJECT $RELEASE
        nextReleaseName
        MPRrel="$MPRdev"$META/$PROJECT/$RELEASE
        if [ ! -d "$MPRrel" ]
        then
                efs create release $META $PROJECT $RELEASE > /dev/null
                for FOLDER in "$MPRrel" "$MPRrel/src" "$MPRrel/install"
                do
                        if [ ! -d "$FOLDER" ]  
                        then
                                echo error: unable to make "$FOLDER"
				echo '###################################################'
                                exit 1
                        fi
                done
        else
                echo $MPRrel already exists
		echo '###################################################'
                exit 1
        fi
	echo '###################################################'
}

function clone 
{	
	echo Cloning to "$MPRrel"/src
	git clone https://MthreeDelegate:AlumniTrain%40M3%2FT1@bitbucket.org/mthree_consulting/javademos.git ""$MPRrel"/src"
	if [[ $? != 0 ]] 
	then
		echo Unable to clone
		exit 1
	fi	
}

function createCommon
{
	echo '###### Running command: ' efs create install $META $PROJECT $RELEASE common
        
        COMMON="$MPRdev"$META/$PROJECT/$RELEASE/install/common
        if [ ! -d "$COMMON" ]
        then
                efs create install $META $PROJECT $RELEASE common
                if [ ! -d "$COMMON" ]
                then
                	echo error: unable to make "$COMMON"
                        echo '###################################################'
                        exit 1
                fi
        else
                echo $COMMON already exists
                echo '###################################################'
                exit 1
        fi
}

function copy
{
	cp -R "$MPRdev"$META/$PROJECT/$RELEASE/src "$MPRdev"$META/$PROJECT/$RELEASE/install/common
	if [[ $? != 0 ]]
	then
		echo Unable to copy
		exit 1
	fi
}

function createReleaseLink
{
	echo Creating Release Link for $RELEASE
	efs create releaselink $META $PROJECT $RELEASE DEV
	if [[ $? != 0 ]]
	then
		echo Unable to create link
		exit 1
	fi
}


function main
{
	inputValidation $@
	createDIR "efs create meta $META" ""$MPRdev""$META""
	createDIR "efs create project $META $PROJECT" ""$MPRdev"$META"/"$PROJECT"
	createRelease
	clone
	createCommon
	copy
	createReleaseLink
	
	exit 0
}

main $@

 
