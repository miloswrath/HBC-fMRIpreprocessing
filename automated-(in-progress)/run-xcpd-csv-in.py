import pandas as pd
import os
import sys
import re

# Function to replace placeholders in the template
def replace_placeholders(template, subject, session):
    # Here we will replace placeholders in the template string with actual values
    # For simplicity, only SUBJECT and SESSION are shown, but will expand with Bryan
    return template.replace("SUBJECT", subject).replace("SESSION", session).replace(singularityDir)

# Read in the csv file
df = pd.read_csv(sys.argv[1])

# Iterate over each row to create job files
for index, row in df.iterrows():
    subject = row['id0']
    session = row['id1']
    run = row['id2']
    img = row['img']

    # Directory naming convention (adjust for correct convention after meeting w/ Bryan)
    output_dir = f"sub-{subject}-{session}"
    full_output_path = os.path.join("fmriprep_v23.2.0", output_dir)
    os.makedirs(full_output_path, exist_ok=True)

    # Create the job file for each row, adding the subject and session
    job_file = f"sub-{subject}-{session}-{run}.job"
    with open(job_file, "w") as f:
        f.write(f"""#!/bin/bash
            #$ -pe smp 56
            #$ -q UI
            #$ -m bea
            #$ -M zjgilliam@uiowa.edu
            #$ -j y
            #$ -o /Shared/vosslabhpc/Projects/BETTER_B2/3-Experiment/2-Data/BIDS/derivatives/code/xcp-d/out
            #$ -e /Shared/vosslabhpc/Projects/BETTER_B2/3-Experiment/2-Data/BIDS/derivatives/code/xcp-d/err
            OMP_NUM_THREADS=10
            singularity run --cleanenv -H ${HOME}/singularity_home -B /Shared/vosslabhpc:/mnt \
            /Shared/vosslabhpc/UniversalSoftware/SingularityContainers/xcp_d_v0.6.1.sif \
            /mnt/Projects/BETTER_B2/3-Experiment/2-Data/BIDS/derivatives/fmriprep_v23.2.0 \
            /mnt/Projects/BETTER_B2/3-Experiment/2-Data/BIDS/derivatives/xcp_d_v0.6.1 \
            participant --participant_label SUBJECT \
            --dummy-scans 5 \
            -f 0.5 \
            --atlases 4S456Parcels
            """)
        f.write(replace_placeholders(f.read(), subject, session))

    # Store an array of each job file
    job_files_array = []
    job_files_array.append(job_file)

# using the array, submit all jobs to the cluster
for job_file in job_files_array:
    os.system(f"qsub {job_file}")
    print(f"Submitted {job_file} to the cluster")





