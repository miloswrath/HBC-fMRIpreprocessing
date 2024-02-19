#!/bin/bash

##############################

#A template to run XCP-D (v3.3) against datasets run through fmriprep


#Assumptions:
#
#  1) Heudiconv has already been run
#  2) fmriprep has already been run

  #By Joel Bruss (joel-bruss@uiowa.edu), 2/2023

##############################

templateDir={directory of the template file}


function printCommandLine {
  echo ""
  echo "Usage: run_xcpd.sh -s subject -S session"
  echo ""
  echo "   where:"
  echo "   -s Subject ID"
  exit 1
}



# Parse Command line arguments
while getopts “hs:S:” OPTION
do
  case $OPTION in
    h)
      printCommandLine
      ;;
    s)
      subject=$OPTARG
      ;;
    S)
      session=$OPTARG
      ;;
    ?)
      printCommandLine
      ;;
     esac
done



  #Base output directory
baseDir={directory of output}

  #logdir and raw NIfTI dir
logDir=${baseDir}/logs/sub-${subject}
if [[ ! -d ${logDir} ]]; then
  mkdir ${logDir}
fi
derivDir=${baseDir}/derivatives

  #Jobs directory
jobDir=${baseDir}/jobs/sub-${subject}
if [[ ! -d ${jobDir} ]]; then
  mkdir ${jobDir}
fi

prepDir=${derivDir}/fmriprep
  #Check for fmriprep output
if [[ ! -d ${prepDir}/sub-${subject} ]]; then
  echo "Error: Data must have been run through fmriprep first!"
  exit 1
fi

xcpDir=${derivDir}
if [[ ! -d ${xcpDir} ]]; then
  mkdir ${xcpDir}
fi

  #Determining User
usr=`whoami`

##########

#Populate the template (create a new job file), make executable
sed -e "s|USER|${usr}|g" \
    -e "s|SUBJECT|${subject}|g" \
    -e "s|SESSION|${session}|g" \
    -e "s|PREPDIR|${prepDir}|g" \
    -e "s|XCPDIR|${xcpDir}|g" \
    -e "s|LOGDIR|${logDir}|g" ${templateDir}/_xcpdTemplate > ${jobDir}/sub-${subject}_xcpd.job

chmod +x ${jobDir}/sub-${subject}_xcpd.job

#Submit the job to Argon
qsub ${jobDir}/sub-${subject}_xcpd.job

