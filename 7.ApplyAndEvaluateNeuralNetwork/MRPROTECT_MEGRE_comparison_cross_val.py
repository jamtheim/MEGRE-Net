import pandas as pd
import csv
import numpy as np
import os
import pdb
import nibabel as nib
import matplotlib.pyplot as plt
from operator import itemgetter
import sys

"""
This script creates #nbr_cross_vals .csv files containing the Dice-
scores of the cross validation run. These files show the resulting Dice-
score for each patient in the cross validation, and also specifies if 
the patient belongs to the training or the validation set.

Furthermore, two other .csv files are created. The first one, named
patients_summary.csv, show the Dice-score for each patient across all
cross validation runs. This is an average over all runs, both the ones
where the patient was in the validation set and the training set. This 
file should be used to find the patients on which it is the hardest to 
locate the gold markers. The second .csv file is named 
Cross_val_summary.csv and summarizes the results from the cross 
validation run.

Make sure the paths are set correctly and that the settings are adjusted
to your run.
"""


""" Settings """
# Import sys arguments as settings to use
iter_nbr = int(sys.argv[1]) 	# Set the iter number here
Radius = sys.argv[2] 			# Set the radius here
nbr_patients = int(sys.argv[3]) # Set the number of patients here
Run = sys.argv[4]				# Inference run number

data_dir = '/mnt/md1/Christian/Projects/MEGRE/Code/MEGRE/models/MEGRE_inf_MRPROTECT_' + str(iter_nbr) + '_GT' + Radius + '_Run' + Run # The path to the results
write_dir = data_dir + "/"
ground_truth_dir = '/mnt/md1/Christian/Projects/MEGRE/Patients40processedN4v2Normalized/GT' + Radius + "/"  # The path to the ground truth


text_file_name = 'MEGRE_inf_' + str(iter_nbr) + '_GT' + Radius + '_comparison_crossval_' # The name of the text file that will contain the results
nbr_cross_vals = np.sum(['cross_' in folder_name for folder_name in os.listdir(data_dir)]) # Find number of cross val folders
""" """


def calculateLoss(prediction, ground_truth, loss = "cross_entropy"):
	prediction = prediction[0].squeeze()
	ground_truth = ground_truth[0].squeeze()
	
	if loss == 'mae' or loss == 'mean_absolute_error':
		loss_value = np.mean(np.abs(prediction-ground_truth))
		return loss_value
	
	# Buggy DICE
	#if loss == "dice":
		#gt_v = np.ndarray.flatten(ground_truth)
		#pred_v = np.ndarray.flatten(prediction)
		#index_ones = np.where(gt_v==1)
		#dice_numerator = 2.0 * np.sum(pred_v[index_ones])
		#dice_denominator = np.sum(np.square(pred_v[index_ones])) + np.sum(gt_v)
		#epsilon = 1e-5
		#dice_score = (dice_numerator + epsilon) / (dice_denominator + epsilon)
		#return np.mean(dice_score)
	# New DICE	
	if loss == "dice":
		gt_v = np.ndarray.flatten(ground_truth)
		pred_v = np.ndarray.flatten(prediction)
		index_ones = np.where(pred_v==1)
		dice_numerator = 2.0 * np.sum(gt_v[index_ones])
		dice_denominator = np.sum(pred_v) + np.sum(gt_v)
		epsilon = 1e-5
		dice_score = (dice_numerator + epsilon) / (dice_denominator + epsilon)
		return np.mean(dice_score)
	
def load_image(image_path, extension=None):

    if extension is None:
        extension = image_path.replace('.',' ').split()[-1]

    if extension == 'nii' or extension == 'gz':
        image_obj = nib.load(image_path)
        image = image_obj.get_data()
        meta = image_obj.get_header()

    return image, meta




""" Preallocation """
result_dict = {}
train_result_list = []
val_result_list = []
patient_score_dict = {}
""" ------------------"""


for kPat in range(nbr_patients):
	if kPat < 9:
		patient_score_dict["Pat0" + str(kPat+1)] = 0
	else:
		patient_score_dict["Pat" + str(kPat+1)] = 0

cross_val_summary_list = []
# Go trough each cross_val folder
for kCross in range(nbr_cross_vals):
	result_list = []
	current_dir = data_dir + "/cross_" + str(kCross+1) + "/"
	with open(current_dir + "dataset_split.csv", 'r') as f:
		reader = csv.reader(f)
		dataset_split = list(reader)
		patient_list = [kPat for kPat in dataset_split]
		validation_list = [kPat for kPat, val_or_train in dataset_split if val_or_train in "validation"]
		training_list = [kPat for kPat, val_or_train in dataset_split if val_or_train in "training"]

	output_dir = current_dir + "output_MRPROTECT/"
	for kFile in os.listdir(output_dir):
		file_name = str(kFile)
		if file_name in "inferred.csv":
			continue
		under_score_ind = file_name.find("_")
		pat_name = file_name[0:under_score_ind+1]
		ground_truth_file = ground_truth_dir + pat_name + 'coords.nii.gz'
		ground_truth = load_image(ground_truth_file)
		
		
		if pat_name in training_list: 
			print('training')
			prediction = load_image(output_dir + file_name)
			dice_loss = calculateLoss(prediction, ground_truth, 'dice')
			result_list.append([pat_name[0:-1], dice_loss,'training'])
			
			
		elif pat_name in validation_list:
			print('validation')
			prediction = load_image(output_dir + file_name)
			dice_loss = calculateLoss(prediction, ground_truth, 'dice')
			result_list.append([pat_name[0:-1],dice_loss,'validation'])

			
			
		elif file_name in "inferred.csv":
			continue
		else:
			print("Unknown patient or other than valdiation/training")
			print(file_name)
	
	result_list.sort(key=itemgetter(0))
	fileName = text_file_name + str(kCross + 1) + ".csv"
	df = pd.DataFrame(result_list)
	df.to_csv(write_dir + fileName, index=False, header=None)
	
	val_mean = 0
	train_mean = 0
	nbr_val = 0
	nbr_train = 0
	for kPat, dice, val_or_train in result_list:
		patient_score_dict[kPat] += dice/nbr_cross_vals

		if val_or_train == "validation":
			val_mean += dice
			nbr_val += 1

		elif val_or_train == "training":
			train_mean += dice
			nbr_train += 1

	if nbr_val > 0:
		val_mean = val_mean / nbr_val
		
	if nbr_train > 0:
		train_mean = train_mean / nbr_train
		
	cross_val_summary_list.append(["Cross_val_" + str(kCross+1), train_mean, val_mean])
	train_result_list.append(train_mean)
	val_result_list.append(val_mean)
	
# Print cross_val_summary_list to csv:
cross_val_summary_list.sort(key=itemgetter(0))
# cross_val_summary_list.append(["TRAINING"])
# cross_val_summary_list.append(["Mean Training (Dice)", np.mean(train_result_list)])
# cross_val_summary_list.append(["Standard dev. Training (Dice)", np.std(train_result_list)])
# cross_val_summary_list.append(["Median Training (Dice)", np.median(train_result_list)])
# cross_val_summary_list.append(["Min Training (Dice)", np.min(train_result_list)])
# cross_val_summary_list.append(["Max Training (Dice)", np.max(train_result_list)])
cross_val_summary_list.append(["VALIDATION"])
cross_val_summary_list.append(["Mean Validation (Dice)", np.mean(val_result_list)])
cross_val_summary_list.append(["Standard dev. Validation (Dice)", np.std(val_result_list)])
cross_val_summary_list.append(["Median Validation (Dice)", np.median(val_result_list)])
cross_val_summary_list.append(["Min Validation (Dice)", np.min(val_result_list)])
cross_val_summary_list.append(["Max Validation (Dice)", np.max(val_result_list)])


# Print Cross_val_summary to csv:
fileName = "Cross_val_summary" + "_MEGRE_inf_" + str(iter_nbr) + "_GT" + Radius + ".csv"
df = pd.DataFrame(cross_val_summary_list)
df.columns = ["File name", "Training (Dice)", "Validation (Dice)"]
df.to_csv(write_dir + fileName, index=False)
	
# Print patient summary to csv:
df = pd.DataFrame([patient_score_dict])
df.to_csv(write_dir + "Patients_summary" + "_MEGRE_inf_" + str(iter_nbr) + "_GT" + Radius + ".csv", index=False)



	
