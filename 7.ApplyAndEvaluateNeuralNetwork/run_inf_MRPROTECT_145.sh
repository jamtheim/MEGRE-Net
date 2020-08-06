# Inference script for MR-PROTECT dataset
# Define input arguments for iteration, radius and chose cross validation to use

Iter=$1 # The iteration number of the model.
Radius=$2 # The radius of the model used
model_cross_val=$3 # Set the cross validation of the model to use
model_iter=$4 # Set what iteration in snapshot-model to use
nbr_cross_val=$5 # How many cross validations to perform (1 due to compability inheritance)
Run=$6 # Set run number

# Define PYTHON environment
source /mnt/md1/Christian/virtual_environment/niftynet/bin/activate
PROJECT=MEGRE

# Make sure that all the paths are correct!
NIFTYNET_PATH=/mnt/md1/Christian/Software/NiftyNet
PROJECT_PATH=/mnt/md1/Christian/Projects/MEGRE/Code

cd ${NIFTYNET_PATH}

if [ -f ${NIFTYNET_PATH}/niftynet/layer/bn_original.py ]
then
    echo Running with BN turned on.
    mv ${NIFTYNET_PATH}/niftynet/layer/bn.py ${NIFTYNET_PATH}/niftynet/layer/bn_off.py
    mv /${NIFTYNET_PATH}/niftynet/layer/bn_original.py ${NIFTYNET_PATH}/niftynet/layer/bn.py
else
    echo Running with BN ALREADY turned on.
fi

for cross_nbr in $(seq 1 $nbr_cross_val)
do
	echo Starting inference on MR-PROTECT data 
	DIR_CROSS=${PROJECT_PATH}/${PROJECT}/models/${PROJECT}_iter_${Iter}_GT${Radius}/cross_$model_cross_val	
	DIR_INF=${PROJECT_PATH}/${PROJECT}/models/${PROJECT}_inf_MRPROTECT_${Iter}_GT${Radius}_Run${Run}/cross_$model_cross_val
	mkdir -p $DIR_INF
	echo Copying trained model to inference directory
	cp -r $DIR_CROSS/models $DIR_INF/models 
	echo Copying split file
	cp ${PROJECT_PATH}/${PROJECT}/src/data/Compute/dataset_split_MRPROTECT/dataset_split_MRPROTECT.csv $DIR_INF/dataset_split.csv
	# Normal
	python net_segment.py inference  --conf ${PROJECT_PATH}/${PROJECT}/src/models/configs/${PROJECT}_inf_MRPROTECT_${Iter}_GT${Radius}.ini --model_dir $DIR_INF --dataset_to_infer all --inference_iter ${model_iter} --save_seg_dir ./output_MRPROTECT
	# With probabilities 
	python net_segment.py inference  --conf ${PROJECT_PATH}/${PROJECT}/src/models/configs/${PROJECT}_inf_MRPROTECT_${Iter}_GT${Radius}_prob.ini --model_dir $DIR_INF --dataset_to_infer all --inference_iter ${model_iter} --save_seg_dir ./output_prob_MRPROTECT
done
