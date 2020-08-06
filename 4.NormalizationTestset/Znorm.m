%% Init file
% clear all
clc
close all
%% Description
% Convert the image volume to normalized volumes with a mean signal value
% of 0 and a standard deviation of 1. This should be performed after
% N4filtering as negative values is not appritiated in the N4 filtering. 

%% Configuration
% Get basedir
basedir = pwd;
addpath(basedir)
% Set data dir
datadir = 'D:\Patients40processedN4v2'; 
% Set dir for export
exportdir = 'D:\Patients40processedN4v2Normalized'; 
% Define number of echoes
necho = 8;
%%
% Create needed directories in output
for currEcho = 1:necho
    mkdir([exportdir '\echo_' num2str(currEcho)])
end

%% Get patient listing for folder echo 1
cd(datadir)
cd ('echo_1')
D = dir;
D = D(~ismember({D.name}, {'.', '..'}));


% For every patient in directory
for k = 1:numel(D)
    tic 
    % Define files of interest, file naming after echo 1 folder (same)
    fnVolumeEcho1 = D(k).name;
    % Get current patient name, split using _
    fnVolumeSplit = strsplit(fnVolumeEcho1,'_');
    patName = fnVolumeSplit{1};
    display(num2str(patName))
    
    % For all echoes
    for currEcho = 1:necho
        fnVolume = [patName '_echo-' num2str(currEcho) '.nii.gz'];
        fnVolumePath = fullfile(datadir, ['echo_' num2str(currEcho)], fnVolume);
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
        
        % Take action segment 
        % Normalize image volume
        volumeNorm = (volume-mean(volume(:))) ./ std(volume(:)) ;

        % QA sement 
        % Collect data
        meanVal(k,currEcho) = mean(volume(:)); 
        stdVal(k,currEcho) = std(volume(:));  
        % Check values 
        if abs(mean(volumeNorm(:))) > 0.01
           error('Mean is too big')            
        end
        
        if abs(std(volumeNorm(:))) > 1.01
            error('STD is not 1')
        end
        
        if abs(std(volumeNorm(:))) < 0.99
            error('STD is not 1')
        end

        % Define output filename
        fnVolumeOut = [patName '_echo-' num2str(currEcho) '.nii.gz'];
        fnVolumeOutPath = fullfile(exportdir, ['echo_' num2str(currEcho)], fnVolumeOut);
        fnVolumeOutPath = erase(fnVolumeOutPath,'.nii.gz'); 
        % Write nifty
        niftiwrite(volumeNorm,fnVolumeOutPath,infoVolume, 'Compressed',true)
    end
        
    cd ..
    cd ('echo_1')
    toc
end

cd(basedir)

% Message
disp('Program is done')


%% Plot if signal is normal distributed
% Otherwise normalization is not valid

subplot(2,4,1)
histogram(meanVal(:,1))
title(['Mean signal echo 1 ' num2str(k) ' pat'])

subplot(2,4,2)
histogram(meanVal(:,2))
title(['Mean signal echo 2 ' num2str(k) ' pat'])

subplot(2,4,3)
histogram(meanVal(:,3))
title(['Mean signal echo 3 ' num2str(k) ' pat'])

subplot(2,4,4)
histogram(meanVal(:,4))
title(['Mean signal echo 4 ' num2str(k) ' pat'])

subplot(2,4,5)
histogram(meanVal(:,5))
title(['Mean signal echo 5 ' num2str(k) ' pat'])

subplot(2,4,6)
histogram(meanVal(:,6))
title(['Mean signal echo 6 ' num2str(k) ' pat'])

subplot(2,4,7)
histogram(meanVal(:,7))
title(['Mean signal echo 7 ' num2str(k) ' pat'])

subplot(2,4,8)
histogram(meanVal(:,8))
title(['Mean signal echo 8 ' num2str(k) ' pat'])
%% 
