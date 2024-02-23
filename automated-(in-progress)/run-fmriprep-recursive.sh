#!/bin/bash

##############################

#A template to run fmriprep (v21.0.0) against datasets extracted from heudiconv
    #Modified by Zak Gilliam (zjgilliam@uiowa.edu)
    #By Joel Bruss (joel-bruss@uiowa.edu), 1/2023

##############################

templateDir=/Volumes/vosslabhpc/Projects/BETTER_IIB/3-Experiment/2-Data/BIDS/code/derivatives/code/fmriprep_v23.2.0/job_scripts/

function printCommandLine {
    echo ""
    echo "Usage: run_fmriprep.sh -s \"subject1 subject2 subject3\""
    echo ""
    echo "   where:"
    echo "   -s Space-separated list of Subject IDs"
    exit 1
}

# Parse Command line arguments
while getopts “hs:” OPTION
do
    case $OPTION in
        h)
            printCommandLine
            ;;
        s)
            subjects=$OPTARG
            ;;
        ?)
            printCommandLine
            ;;
         esac
done

# Split the subjects string into an array
IFS=' ' read -r -a subjectArray <<< "$subjects"

# Iterate over the subjects and create .job files
for subject in "${subjectArray[@]}"
do
    #Base output directory
    baseDir=/Volumes/vosslabhpc/Projects/BETTER_IIB/3-Experiment/2-Data/BIDS/derivatives

    #logdir and raw NIfTI dir
    logDir=${baseDir}/logs/sub-${subject}
    if [[ ! -d ${logDir} ]]; then
        mkdir ${logDir}
    fi
    inDir=${baseDir}

    #Jobs directory
    jobDir=${baseDir}/jobs/sub-${subject}
    if [[ ! -d ${jobDir} ]]; then
        mkdir ${jobDir}
    fi

    #Check for NIfTI
    if [[ ! -d ${inDir}/sub-${subject} ]]; then
        echo "Error: Data must have been run through heudiconv first!"
        exit 1
    fi

    #Output Directory
derivDir=${baseDir}/derivatives/fmriprep_v23.2.0/out

    #Determining User
    usr=`whoami`

    ##########

    #Populate the template (create a new job file), make executable
    sed -e "s|USER|${usr}|g" \
            -e "s|SUBJECT|${subject}|g" \
            -e "s|INDIR|${inDir}|g" \
            -e "s|DERIVDIR|${derivDir}|g" \
            -e "s|LOGDIR|${logDir}|g" ${templateDir}/_fmriprepTemplate > ${jobDir}/sub-${subject}_fmriprep.job

    chmod +x ${jobDir}/sub-${subject}_fmriprep.job

    # Do not submit the job to Argon - still need to modify to exclude recursion
    # qsub ${jobDir}/sub-${subject}_fmriprep.job
done