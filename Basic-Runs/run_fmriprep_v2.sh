#!/bin/bash

# sublist='sub-2002'


for sub in $(cat /Shared/vosslabhpc/Projects/BikeExtend/3-Experiment/2-Data/BIDS/code/fmriprep_v23_xcpD_TEST.txt); do

echo ${sub}
subname=$(basename ${sub} | sed "s/sub-//");
echo $subname
cd /Shared/vosslabhpc/Projects/BikeExtend/3-Experiment/2-Data/BIDS/derivatives/code/fmriprep_v23.2.0/job_scripts 

##############################

#A template to run fmriprep (v21.0.0) against datasets extracted from heudiconv


#Assumptions:
#
#  1) Heudiconv has already been run
  #Modified by Zak Gilliam (zjgilliam@uiowa.edu)
  #By Joel Bruss (joel-bruss@uiowa.edu), 1/2023

##############################

templateDir="/Shared/vosslabhpc/Projects/BikeExtend/3-Experiment/2-Data/BIDS/derivatives/code/fmriprep_v23.2.0/job_scripts"


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
baseDir="/Shared/vosslabhpc/Projects/BikeExtend/3-Experiment/2-Data/BIDS"

inDir=${baseDir}

  #Jobs directory
jobDir="${baseDir}/derivatives/code/fmriprep_v23.2.0/job_scripts/sub-${subname}"


  #Output Directory
derivDir="${baseDir}/derivatives"

  #Determining User
usr=`whoami`

##########

#Populate the template (create a new job file), make executable
sed -e "s|SUBJECT|${subname}|g" fmriprepTemplate.job > ${PWD}/sub-${subname}.job


chmod +x ${PWD}/sub-${subname}.job

#Submit the job to Argon
qsub ${PWD}/sub-${subname}.job

done
