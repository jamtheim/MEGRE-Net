%% Init file
%clear all
clc
% close all
%%

%% Configuration
% Get basedir
basedir = pwd;
addpath(basedir)
% Set data dir
datadir = 'D:\Patients176processedN4v2\';
% Define number of echoes
necho = 8;
% Define number of radius
nradius = 12;
% Define randomized rotation range angle other than 0 degrees
minRot = -15;
maxRot = 15;
% Define randomized noise level boundaries
minNoise = 0;
maxNoise = 0;
% Number of patients in material
npat = 176;
%%

%% Get patient listing for folder echo 1
cd(datadir)
cd ('echo_1')
D = dir;
D = D(~ismember({D.name}, {'.', '..'}));

% For every patient in directory
for k = 1:numel(D)
    % Randomize rotation angle
    angle = 0;
    while angle == 0
        angle = randi([minRot maxRot],1,1);
    end
    % Randomize noise level to add
    noiseLevel = randi([minNoise maxNoise],1,1);
    % Define files of interest, file naming after echo 1 folder (same)
    fnVolumeEcho1 = D(k).name;
    % Get current patient name, split using _
    fnVolumeSplit = strsplit(fnVolumeEcho1,'_');
    patName = fnVolumeSplit{1};
    % Get patient number
    patNameSplit = strsplit(patName,'Pat');
    % Strip away leading zeros
    patNumber = str2num(patNameSplit{2});
    % Define new patient number
    patNewNumber = npat + patNumber;
    % Define new patient name
    patNewName = ['Pat' num2str(patNewNumber)];
    disp([num2str(patName)])
    disp([num2str(patNewName)])
    
    % For all echoes
    for currEcho = 1:necho
        fnVolume = [patName '_echo-' num2str(currEcho) '.nii.gz'];
        fnVolumePath = fullfile(datadir, ['echo_' num2str(currEcho)], fnVolume);
        %disp([num2str(fnVolumePath)])
        %Read info and data for volume
        volume = niftiread(fnVolumePath);
        infoVolume = niftiinfo(fnVolumePath);
        infoVolume.Description = 'Modified by CJG using MATLAB R2019a';
        % For images that have been N4 filtered using SimpleITK the
        % Transformname must be changed. Otherwise the image is displayed
        % upside down in ITK-SNAP. 
        % Set TransformName to Sform to solve the problem.
        % Documentation on this problem exists. 
        % Not 100% sure why this works
        infoVolume.TransformName = 'Sform';  
        % Rotate volume
        volumeRot = rotateMatrix(volume,angle,'typeVolume');
        
        % Add Gauss noise
        % volumeRot = addGaussNoise(volumeRot, noiseLevel);
        
        % Define output filename
        fnVolumeOut = [patNewName '_echo-' num2str(currEcho) '.nii.gz'];
        fnVolumeOutPath = fullfile(datadir, ['echo_' num2str(currEcho)], fnVolumeOut);
        % fnVolumeOutPath = insertBefore(fnVolumeOutPath,'.nii.gz',['_rot' num2str(angle) '_nl' num2str(noiseLevel)]);
        fnVolumeOutPath = erase(fnVolumeOutPath,'.nii.gz');
        % Write nifty
        niftiwrite(volumeRot,fnVolumeOutPath,infoVolume, 'Compressed',true)
        % Display
        % disp([num2str(fnVolumeOutPath)])
    end
    
    % For all labels
    fnLabel = [patName '_coords.nii.gz'];
    fnLabelOut = [patNewName '_coords.nii.gz'];
    % For every radius do
    for currRadius = 1:nradius
        % Define label path
        fnLabelPath = fullfile(datadir, ['GT' num2str(currRadius)],fnLabel);
        % Read info and data for Label
        label = niftiread(fnLabelPath);
        infoLabel = niftiinfo(fnLabelPath);
        infoLabel.Description = 'Modified by CJG using MATLAB R2019a';
        % No need to change TransformName here as these images where never
        % N4 filtered. 
        % Rotate label
        labelRot = rotateMatrix(label,angle,'typeLabel');
        % Define output filename
        fnLabelOutPath = fullfile(datadir, ['GT' num2str(currRadius)],fnLabelOut);
        % fnLabelOutPath = insertBefore(fnLabelOutPath,'.nii.gz',['_rot' num2str(angle) '_nl' num2str(noiseLevel)]);
        fnLabelOutPath = erase(fnLabelOutPath,'.nii.gz');
        % Write nifty
        niftiwrite(labelRot,fnLabelOutPath,infoLabel,'Compressed',true)
        % Display
        % disp(num2str(fnLabelOutPath))
    end
    
    cd ..
    % displayRotation(volume, volumeRot, label, labelRot, patName, angle)
    cd ('echo_1')
end

cd(basedir)

% Message
disp('Done')
