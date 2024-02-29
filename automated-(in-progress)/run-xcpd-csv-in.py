import pandas as pd
import os
import sys

# Function to replace placeholders in the template
def replace_placeholders(template, subject, session, singularityDir, scriptDir, user):
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

    # Read the template job file
    with open('_xcpdTemplate', 'r') as file:
        template_content = file.read()

    # Replace placeholders in the template with actual values
    job_file_content = replace_placeholders(template_content, subject, session)

    # Path for the new job file
    job_file_path = os.path.join(full_output_path, f"job_{subject}_{session}_{run}.sh")

    # Write the modified content to the new job file
    with open(job_file_path, 'w') as job_file:
        job_file.write(job_file_content)



