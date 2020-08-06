main() {
	#DIR_DATA_POOL="/home/shared/projekt/MriPlanner/bilder/Lund/MEGRE/MEGRE40/"
	# All folders in DIR_DATA were copied to /scratch2 and renamed " " -> "_"
	DIR_DATA="/mnt/md1/Christian/Projects/MEGRE/Patients176"
	DIR_DATA_OUT="/mnt/md1/Christian/Projects/MEGRE/Patients176processed/"
	echo $DIR_DATA

	list_pat=$(find $DIR_DATA -mindepth 1 -maxdepth 1 -type d)
	# echo $list_pat[@]
	# exit
	for folder in $list_pat
	do
		echo $folder
		echo Sorting folder: "$folder" 
		process_patient $folder
	done


}
process_patient() { 
	DIR_DCM="$1"
	list_dcm=$(ls $DIR_DCM/*.dcm)

	DIR_BIN=/mnt/md1/Christian/Software/c3d-1.1.0-Linux-x86_64/bin/
	
	
	
	for int in 1 2 3 4 5 6 7 8
	do
		mkdir -p $DIR_DCM/[$int]
	done
	for dcm in $list_dcm
	do
		line=$(dcmdump $dcm |grep EchoNumbers)
		# read the line for info on which sequence the file belongs to.
		var=$(echo $line |cut -f3 -d ' ')
		#echo $var
		# var=$(echo $line |cut -f2 -d[)
		# var=$(echo $var |cut -f1 -d])
		# echo $var
		mv $dcm $DIR_DCM/$var/
	done
	
	name=$(echo $(basename $DIR_DCM)|cut -f1 -d_)
	echo $name
	
	
	for int in 1 2 3 4 5 6 7 8
	do
		series_info=$($DIR_BIN/c3d -dicom-series-list $DIR_DCM/[$int])
		# echo $series_info
		series_ID=$(echo $series_info  |cut -f10 -d ' ')
		# echo $series_ID
		mkdir -p ${DIR_DATA_OUT}/echo_${int}
		$DIR_BIN/c3d -dicom-series-read $DIR_DCM/[$int] $series_ID -o ${DIR_DATA_OUT}/echo_${int}/${name}_echo-${int}.nii.gz
	done

}
main "$@"
