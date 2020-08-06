# File for batch inference using a trained model applied to the MR-PROTECT Patients40 dataset

# Define PYTHON environment
source /mnt/md1/Christian/virtual_environment/niftynet/bin/activate

# Run number for the inference trial
Run=1
# Define trained model iteration to be applied
Iter=145
# Define radius used to train that model
Radius=9
# Define which cross validation of that model to use
model_cross_val=4
# Set which iteration-stop to use as many snapshot-models exist (set to -1 for largest iteration)
model_iter=40000
# Set number of peaks for the analasys
nbr_of_peaks=3
# Define number of patients in inference dataset
nbr_patients=40
# Define how many cross validations of this to run (compability inheritance, set to 1)
nbr_cross_val=1
 
# Start inference on the dataset for each crossvalidation
# Make sure the right ini-files have been created.
bash run_inf_MRPROTECT_${Iter}.sh ${Iter} ${Radius} ${model_cross_val} ${model_iter} ${nbr_cross_val} ${Run}
# Start calculate the DICE-measures
python3 MRPROTECT_MEGRE_comparison_cross_val.py ${Iter} ${Radius} ${nbr_patients} ${Run}
# Start calculate the markers distances and components with convolution method
# python3 MRPROTECT_MEGRE_metric_for_article_components.py ${Iter} ${Radius} ${nbr_patients} ${nbr_cross_val} ${nbr_of_peaks} ${Run}

echo Inference on MR-PROTECT is done!
