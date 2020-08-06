function [noisyVolume] = addGaussNoise(volume, noiseLevel)
% Add Gaussian noice with zero mean to the image

% Get mid slice
midSlice = round(size(volume,3)/2); 
% Generate noise volume
noise = noiseLevel * randn(size(volume));
% Add noise
noisyVolume = volume + noise; 

figure(3)
imshow(noisyVolume(:,:,midSlice),[])