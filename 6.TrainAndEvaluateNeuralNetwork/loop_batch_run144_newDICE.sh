# File for batch running over multiple parameters
# This file defines the 85/15 split. 
# Please change nbr_patients_for_val to achieve other split ratios. 

# Define PYTHON environment
source /mnt/md1/Christian/virtual_environment/niftynet/bin/activate

# Define parameters used
Iter=144
# Radius= / See loop
nbr_patients=652
nbr_patients_for_val=98
nbr_cross_val=5
nbr_of_peaks=3

# Create cross validation data
python3 create_cross_val_data.py ${Iter} ${nbr_patients} ${nbr_patients_for_val} ${nbr_cross_val}
	
# Lopp over selected variable
# Make sure the right ini-files have been created. 
# for Radius
for Radius in 9
do
	# Start calculation and cross validation 
	bash run_iter.sh ${Iter} ${Radius} ${nbr_cross_val}
	# Start inference
	bash run_iter_inference_144_GPU1.sh ${Iter} ${Radius} ${nbr_cross_val}
	bash run_iter_inference_144_prob.sh ${Iter} ${Radius} ${nbr_cross_val}
	# Start calculate the DICE-measures
	python3 MultiInfer_MEGRE_comparison_cross_val_326.py ${Iter} ${Radius} ${nbr_patients} 40000

done

echo Program is done!
