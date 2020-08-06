import pandas as pd
import numpy as np
import pdb
import os
import shutil
import sys 

""" Settings """
# Import sys arguments as settings to use
iter_nbr = int(sys.argv[1]) # Iteration number
nbr_patients = int(sys.argv[2]) # The number of patients
nbr_patients_for_val = int(sys.argv[3]) # How many patients in each validation set
nbr_cross_vals = int(sys.argv[4]) # Number of cross validation runs.
"""  """

# Create directory /Christian	
OUTPUT_FOLDER="dataset_split_" + str(iter_nbr)
# Remove if existing
if os.path.exists(OUTPUT_FOLDER):
	shutil.rmtree(OUTPUT_FOLDER)
if not os.path.exists(OUTPUT_FOLDER):
	os.mkdir(OUTPUT_FOLDER)

patients_for_val = np.random.choice(nbr_patients, size=(nbr_cross_vals, nbr_patients_for_val), replace=False)+1
"""
Format the names of the patients so that if it is a patient with a 
number < 10, it will append a 0 in front of it.
"""
# pdb.set_trace()
patient_nbr_list = [str(kPat) for kPat in range(10,nbr_patients+1)] 
temp_list = ['0' + str(kPat) for kPat in range(1,10)]

patient_nbr_list =temp_list + patient_nbr_list
patient_list = ["Pat" + kPat + "_" for kPat in patient_nbr_list]
# pdb.set_trace()
for k_cross_val in range(nbr_cross_vals):
	training_or_val_list = ["training" for kPatients in range(nbr_patients)]
	for k_patient in range(nbr_patients):
		if k_patient+1 in patients_for_val[k_cross_val,:]:
			training_or_val_list[k_patient] = "validation"
	
	dict_for_cvs_file = {"patient": patient_list,"training/validation": training_or_val_list}
	df = pd.DataFrame(dict_for_cvs_file)
	fileName = "dataset_split_cross_" + str(iter_nbr) + "_" + str(k_cross_val+1) + ".csv"
	df.to_csv(fileName, index=False, header=None)
	shutil.move(fileName, OUTPUT_FOLDER) # /Christian  


