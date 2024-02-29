#!/bin/bash

##############################

#A template to run fmriprep (v21.0.0) against datasets extracted from heudiconv


#Assumptions:
#
#  1) Heudiconv has already been run
  #Modified by Zak Gilliam (zjgilliam@uiowa.edu)
  #By Joel Bruss (joel-bruss@uiowa.edu), 1/2023

##############################

templateDir="/Shared/vosslabhpc/Projects/BETTER_IIB/3-Experiment/2-Data/BIDS/derivatives/code/fmriprep_v23.2.0/job_scripts/"


function printCommandLine {
  echo ""
  echo "Usage: run_fmriprep.sh -s subject"
  
  echo ""
  echo "   where:"
  echo "   -s Subject ID"
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
      subject=$OPTARG
      ;;
    ?)
      printCommandLine
      ;;
     esac
done



  #Base output directory
baseDir= "/Shared/vosslabhpc/Projects/BETTER_IIB/3-Experiment/2-Data/BIDS"

  #logdir and raw NIfTI dir
logDir="${baseDir}/derviatives/code/fmriprep_v23.2.0/"
if [[ ! -d ${logDir} ]]; then
  mkdir ${logDir}
fi
inDir=${baseDir}

  #Jobs directory
jobDir="${baseDir}/derivatives/code/fmriprep_v23.2.0/job_scripts/sub-${subject}"
if [[ ! -d ${jobDir} ]]; then
  mkdir ${jobDir}
fi


  #Output Directory
derivDir="${baseDir}/derivatives"

  #Determining User
usr=`whoami`

##########

#Populate the template (create a new job file), make executable
sed -e "s|USER|${usr}|g" \
    -e "s|SUBJECT|${subject}|g" templateDir/_fmriprepTemplate.job > ${jobDir}/sub-${subject}_fmriprep.job

chmod +x ${jobDir}/sub-${subject}_fmriprep.job

#Submit the job to Argon
qsub ${jobDir}/sub-${subject}_fmriprep.job

