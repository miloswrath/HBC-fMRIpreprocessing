#!/bin/bash

##############################

#A template to run XCP-D (v3.3) against datasets run through fmriprep


#Assumptions:
#
#  1) Heudiconv has already been run
#  2) fmriprep has already been run

  #By Joel Bruss (joel-bruss@uiowa.edu), 2/2023

##############################


for sub in $(cat /Shared/vosslabhpc/Projects/BETTER_B2/3-Experiment/2-Data/BIDS/code/fmriprep_v23_pilot.txt); do
echo ${sub}
subname=$(basename ${sub} | sed "s/sub-//");
echo $subname
cd /Shared/vosslabhpc/Projects/BETTER_B2/3-Experiment/2-Data/BIDS/derivatives/code/xcp-d/job_scripts 

templateDir="/Shared/vosslabhpc/Projects/BETTER_B2/3-Experiment/2-Data/BIDS/derivatives/code/xcp-d/job_scripts"


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
      echo "ERROR: Invalid subject or session identifier! Please retry the command."
      printCommandLine
      ;;
     esac
done



  #Base output directory
baseDir="/Shared/vosslabhpc/Projects/BETTER_B2/3-Experiment/2-Data/BIDS"

  
derivDir="${baseDir}/derivatives"


prepDir=${derivDir}/fmriprep_v23.2.0
  #Check for fmriprep output
if [[ ! -d ${prepDir}/sub-${subname} ]]; then
  echo "Error: Data must have been run through fmriprep first!"
  exit 1
fi


  #Determining User
usr=`whoami`

##########

#Populate the template (create a new job file), make executable
sed -e "s|SUBJECT|${subname}|g" xcpdTemplate.job > ${PWD}/sub-${subname}.job


chmod +x ${PWD}/sub-${subname}.job

#Submit the job to Argon
qsub ${PWD}/sub-${subname}.job

done
