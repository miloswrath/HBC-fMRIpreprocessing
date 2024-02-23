import pandas as pd
import os
import sys

# Read in the csv file
df = pd.read_csv(sys.argv[1])

# Get the subject list with columns = {subject id, session id, run id, img}
subject_list = df[['id0', 'id1', 'id2']].drop_duplicates()

#create the output directory by using the subject list
output_dir = "fmriprep_v23.2.0/{a}".format(a=df['id0'] + "_" + df['id1'] + "_" + df['id2'])
os.makedirs(output_dir, exist_ok=True)

#create a job file for each subject
for index, row in subject_list.iterrows():
    subject = row['id0']
    session = row['id1']
    run = row['id2']
    img = df[(df['id0'] == subject) & (df['id1'] == session) & (df['id2'] == run)]['img'].values[0]
