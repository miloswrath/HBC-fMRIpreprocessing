#!/bin/bash

##############################

#A template to run XCP-D (v3.3) against datasets run through fmriprep

#Assumptions:
#
#  1) Heudiconv has already been run
#  2) fmriprep has already been run

  #By Joel Bruss (joel-bruss@uiowa.edu), 2/2023
  #Modified by: {Zachary Gilliam}, {02/24}

  #this modification includes the ability to run multiple subjects at once, 
##############################

templateDir={directory of the template file}

function printCommandLine {
  echo ""
  echo "Usage: run_xcpd.sh -s \"subject1 subject2 subject3\" -S session"
  echo ""
  echo "   where:"
  echo "   -s Space-separated list of Subject IDs"
  echo "   -S Session ID"
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
      subjects=$OPTARG
      ;;
    S)
      session=$OPTARG
      ;;
    ?)
      echo "ERROR: Invalid subject or session identifier! Please retry the command."
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

  # Do not submit the job to Argon
  # qsub ${jobDir}/sub-${subject}_xcpd.job

  #!/bin/bash
## Add a check that only submits jobs with an output of fmriprep. Make jobs is doing the filtering on datacheck
for sub in $(); do
    if [ -d ${derivDir}/fmriprep/sub-${sub} ]; then
        qsub ${jobDir}/sub-${sub}_xcpd.job
    fi
    done
    #End of loop
    done

done