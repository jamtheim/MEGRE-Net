# MEGRE-Net
Deep Neural network for automatic gold fiducial marker identification in multi echo gradient echo MRI (MEGRE) images.\
This repository contains scripts, config files and software used in the publication "Development and evaluation of a deep learning based artificial intelligence for automatic identification of gold fiducial markers in an MRI-only prostate radiotherapy workflow" by Jamtheim Gustafsson et al 2020 Phys. Med. Biol. https://doi.org/10.1088/1361-6560/abb0f9. 
Please connect the numbers in the list below to the number of corresponding file folder in the repository. 

1. Conversion of Matlab fiducial coordinates and conversion of a fiducial RT-struct to binary masks/segments 
2. Sorting MEGRE data into folder structure with separate echo numbers 
3. N4 Bias correction of MEGRE data 
4. Normalization of testset data
5. Augmentation of training and validation data (one axis rotation) 
6. Training/evaluation of the neural network
7. Applying the trained model to testset data
8. Evaluation of model performance and calculation of BeAware score
9. Placeholder for the final model file

Validation of MEGRE images can be found in the study Gustafsson, C., et al. (2017). "Registration free automatic identification of gold fiducial markers in MRI target delineation images for prostate radiotherapy." Med Phys 44(11): 5563-5574.

All datasets, annotations and the final model used in this study are publicly available and anonymized for non-commercial use. Please see the file OpenDatasetPublic.txt for data set access instructions or see https://datasets.aida.medtech4health.se/10.23698/aida/megre. Please be aware that adaptations to new patient subject names have to be made to the code in this repository to be compatible with the anonymized file names in the publicly open dataset. \
Contact: christian.JamtheimGustafsson@skane.se
