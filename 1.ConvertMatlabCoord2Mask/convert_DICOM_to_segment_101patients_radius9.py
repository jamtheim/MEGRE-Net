import pydicom
import numpy as np
import os
import pdb
import subprocess

# Only for testing, change to the correct folders when running.
# DIR_IMAGE specifies where the final images are (nii.gz-files)
DIR_IMAGE="/mnt/md1/Christian/Projects/MEGRE/Patients101processed/echo_1/"
# DIR_DATA_OUT specifies where the final ground truth images will be stored
DIR_DATA_OUT="/mnt/md1/Christian/Projects/MEGRE/Patients101processed/GT9/"
# text_file contains the list of patients and the correpsonding coordinates of the gold markers.
# this list should be arranged as:


"""
Patient 1 
x-coordingate gold marker 1 y-coordingate gold marker 1  z-coordingate gold marker 1
x-coordingate gold marker 2 y-coordingate gold marker 2  z-coordingate gold marker 2
x-coordingate gold marker 3 y-coordingate gold marker 3  z-coordingate gold marker 3
Patient 2
...
"""
text_file = "AllCoordinatesOutDICOM_edited.txt" # Containing the correct DICOM coordinates. 
# OBS!!!! THIS SCRIPT WILL DO THE MIRRORING OF THE X- AND Y-COORDINATES! 

# Path to the c3d binary
C3D="/mnt/md1/Christian/Software/c3d-1.1.0-Linux-x86_64/bin/c3d"

# Radius of the gold marker label.
radius = 9

def getPatientDict(text_file_path):
	text_file_temp = open(text_file_path, "rt")
	patient_data = []
	patient_index = []
	index_counter = 0
	patient_number = []
	for line in text_file_temp:
		patient_data.append(line)
		if "Patient" in line:
			patient_index.append(index_counter)
			if len(line[7:].strip()) == 1:# 7 letters in "Patient"
				patient_number.append("0"+line[7:].strip()) 
			else:
				patient_number.append(line[7:].strip())
		index_counter += 1
	text_file_temp.close()
	patient_index.append(len(patient_data)) # So we can see how many gold markers that are inserted.
	# Create a dictionary for all patients
	nbr_patients = len(patient_number)
	patient_dict = {}
	for kPatient in range(nbr_patients):
		coordinates = []
		for kRow in range(patient_index[kPatient]+1, patient_index[kPatient+1]):
			coordinates.append(patient_data[kRow].split())
		coordinates = [coordinate for coordinate in coordinates if coordinate != []]	
		patient_dict.update({"Patient " + patient_number[kPatient]: coordinates})
	return patient_dict




patient_dict = getPatientDict(text_file)
for patient, coordinates in patient_dict.items():
	patient_num = patient.split()[1]
	print("Patient number is: " + patient_num)
	image_file = DIR_IMAGE + "Pat" + str(patient_num) + "_echo-1.nii.gz"
	text_file="temp_coordinates.txt"
	try:
		f = open(text_file, "w+")
		for coordinate in coordinates:
			for value in enumerate(coordinate):
				if value[0] < 2:
					f.write("%.2f" % round(-float(value[1]),2) + " ")
				else:
					f.write("%.2f" % round(float(value[1]),2) + " ")
			f.write("1")	# Valuen of the pixel corresponding to the centre of the gold marker.
			f.write("\n")	
		f.close()
	except:
		print("Could not write to the text-file!")

	cmd = C3D +" " + image_file + " -scale 0 -landmarks-to-spheres \"temp_coordinates.txt\" " + str(radius) +  " -o " + DIR_DATA_OUT + "/Pat" + patient_num + "_coords.nii.gz"
	try:
		return_value = subprocess.call(cmd, shell=True)
	except:	
		print("An exception occured with error message: " + return_value + ". Probably something wrong with the paths." )








	
	
