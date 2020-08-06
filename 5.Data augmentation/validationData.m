%% Init
clc
%%

%% Configuration
% Get basedir
basedir = pwd;
addpath(basedir)
% Data dir
datadir = 'D:\DataOfflineAugN4_150'; 
% Patient
patName = 'Pat11'; 
patNameRot = 'Pat161'; 
currEcho = 4; 
currRadius = 4; 

%%
% Orig Volume
fnVolume = [patName '_echo-' num2str(currEcho) '.nii.gz'];
fnVolumePath = fullfile(datadir, ['echo_' num2str(currEcho)], fnVolume);
% Rot Volume
fnVolumeRot = [patNameRot '_echo-' num2str(currEcho) '.nii.gz'];
fnVolumeRotPath = fullfile(datadir, ['echo_' num2str(currEcho)], fnVolumeRot);
% Read volume
volume = niftiread(fnVolumePath);
volumeRot = niftiread(fnVolumeRotPath);

% Label
fnLabel = [patName '_coords.nii.gz'];
fnLabelPath = fullfile(datadir, ['GT' num2str(currRadius)],fnLabel);
% Rot Label
fnLabelRot = [patNameRot '_coords.nii.gz'];
% fnLabelRot = insertBefore(fnLabelRot,'.nii.gz',['_rot' num2str(rotation)]);
fnLabelRotPath = fullfile(datadir, ['GT' num2str(currRadius)],fnLabelRot);
% Read label
label = niftiread(fnLabelPath);
labelRot = niftiread(fnLabelRotPath);

% Display
% Get slices where we have a label values = 1
i = 0;
for n = 1:size(labelRot,3)
    if sum(sum(labelRot(:,:,n))) > 0
        i = i + 1;
        index(i)= n;
         %i
    end
end

% Check second slice
slice = index(3);
slice
% Figure
f = figure(1); 
imshow(volume(:,:,slice)+1000*label(:,:,slice),[])
f = figure(2); 
imshow(volumeRot(:,:,slice)+1000*labelRot(:,:,slice),[])


%%