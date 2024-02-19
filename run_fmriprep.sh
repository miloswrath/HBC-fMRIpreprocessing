#!/bin/bash

##############################

#A template to run fmriprep (v21.0.0) against datasets extracted from heudiconv


#Assumptions:
#
#  1) Heudiconv has already been run

  #By Joel Bruss (joel-bruss@uiowa.edu), 1/2023

##############################

templateDir={directory of the template file}


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
baseDir= {directory of output}

  #logdir and raw NIfTI dir
logDir=${baseDir}/logs/sub-${subject}
if [[ ! -d ${logDir} ]]; then
  mkdir ${logDir}
fi
inDir=${baseDir}/rawdata

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
derivDir=${baseDir}/derivatives/fmriprep

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

#Submit the job to Argon
qsub ${jobDir}/sub-${subject}_fmriprep.job

