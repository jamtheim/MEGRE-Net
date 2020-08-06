function [beAwareScore] = beAwareMonitor(PatName,inputProbVolume,inputProbVolumeConv,objectSegmAll,objectSegmInd,nrObject,description,DataSetUsed)
%% Monitor if there is reason to be careful with the output of the neural net.
% Checks how much of the total un-convolved signal is contained within the 3 most likely
% objects, compared to the total un-convolved signal in the probability map.
% Also takes into account the average signal in each object

% Quality check of data input
if size(objectSegmInd,4) ~= nrObject
    error('Amount of points inputed is not the same as number of spheres defined in beAware Monitor')
end

sumThreshold = 0.0; 
% sumThreshold = 0.501;

% Preallocate matrix
meanProbObj = zeros(1,size(objectSegmInd,4));
% Get threshold segmentation
ThSegm = inputProbVolume>=sumThreshold; 
% Get pixels of interest depening on threshold
ProbVolumeThresholded = inputProbVolume .* ThSegm;
% Get sum of the thresholded probability map volume
sumProbVolumeThresholded = sum(ProbVolumeThresholded(:)); 

% Get sum of all probability within all objects
ProbObjAll = inputProbVolume .* objectSegmAll;
sumProbObjAll = sum(ProbObjAll(:)); 

% Calculate average probability value inside of each object. Use the
% individual segmentations which are generated artificially perfect.
for i = 1:size(objectSegmInd,4)
    currObjectSegm = objectSegmInd(:,:,:,i);
    currObjectProb = inputProbVolume .* currObjectSegm;
    % Get mean probabilty per pixel in volume
    meanProbObj(1,i) = sum(currObjectProb(:)) / sum(currObjectSegm(:));
end


% Calculate the certainty metric by taking the ratio of the total probability in
% all the objects divided by all thresholded probabilities in the volume and multiply this with each of the mean
% probabilities in each object. 
beAwareScore = sumProbObjAll / sumProbVolumeThresholded  * prod(meanProbObj); 

% End function
end




