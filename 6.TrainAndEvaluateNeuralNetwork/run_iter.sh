# Define input arguments for iteration, radius and number of cross validations
# Calling the file is performed by bash run_iter.sh 110 6 5 for iteration 110, radius 6, and 5 cross validations

Iter=$1 # The iteration number. 
Radius=$2 # The radius to use
nbr_cross_val=$3 # Set the number of cross validations defined in "create_cross_val_data.py"

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
	echo Starting iter $cross_nbr	
	DIR_CROSS=${PROJECT_PATH}/${PROJECT}/models/${PROJECT}_iter_${Iter}_GT${Radius}/cross_$cross_nbr	
	mkdir -p $DIR_CROSS
	cp ${PROJECT_PATH}/${PROJECT}/src/data/Compute/dataset_split_${Iter}/dataset_split_cross_${Iter}_${cross_nbr}.csv $DIR_CROSS/dataset_split.csv
	python net_segment.py train  --conf ${PROJECT_PATH}/${PROJECT}/src/models/configs/${PROJECT}_iter_${Iter}_GT${Radius}.ini --model_dir $DIR_CROSS
done
