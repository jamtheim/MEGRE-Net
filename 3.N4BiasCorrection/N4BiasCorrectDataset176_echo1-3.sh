main() {
	DIR_DATA="/mnt/md1/Christian/Projects/MEGRE/Patients176processed"
	DIR_DATA_OUT="/mnt/md1/Christian/Projects/MEGRE/Patients176processedN4"
	# Echo information
	echo Data in $DIR_DATA
	echo Data out $DIR_DATA_OUT
	# List patients
	list_pat=$(find $DIR_DATA -mindepth 1 -maxdepth 1 -type d)
	# echo $list_pat[@]
	# exit
	# Set directory for python file
	DIR_BIN="/mnt/md1/Christian/Projects/MEGRE/Code/MEGRE/src/data/Create_patient_data_and_GT/SITK_N4Bias"
	# Loop over echoes	
	for int in 1 2 3
		do
		# Create output dir
		mkdir -p $DIR_DATA_OUT/echo_$int
		# List nii.gz files
		list_niigz=$(ls $DIR_DATA/echo_$int/*.nii.gz)
		# Get path
		for patientpath in $list_niigz
		do
		# Cut out patient name
		patientname=$(echo $(basename $patientpath)|cut -f1 -d_)
		echo echo $int
		echo $patientname
		# Execute N4 bias correction
		python ${DIR_BIN}/N4BiasCorrNewMask.py ${DIR_DATA}/echo_${int}/${patientname}_echo-${int}.nii.gz ${DIR_DATA_OUT}/echo_${int}/${patientname}_echo-${int}.nii.gz
		# For QA tests
		# cp ${DIR_DATA}/echo_${int}/${patientname}_echo-${int}.nii.gz ${DIR_DATA_OUT}/echo_${int}/${patientname}_echo-${int}.nii.gz
		done
	done
}

main "$@"
