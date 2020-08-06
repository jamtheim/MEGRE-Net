% This is code to determine the three most likely objects to be fiducial markers
% in the probability maps produced from NiftyNet.
% Probability maps can be outputted if one use output_prob = True in
% NiftyNet ini file.
% This code creates a mask from the concolved probability maps which is then
% saved as a new NIFI mask file file.
% This post processing should wash away any spurious signal and false
% positive marker segments.

%% OBSERVE THAT NIFTYNET IMAGES ARE ROTATED, THEREBY BE CAREFUL WHEN REPORTING NUMBERS
% FOR ROW, COLUM, SLICE and X, Y, Z.
%%
clc
close all
clear all
%%

%% CONFIG AND PARAMETER SETTINGS
% Set what dataset is used
% Added suffix for iteration of model experiment
% Not needed for GT but put it there for simplicity and consistancy
%%
%experimentIteration = 144;
% modelIteration = 40000;
%DataSetUsed = ['TrainingData_' num2str(experimentIteration)];

%% For MR-PROTECT
experimentIteration = 147;
modelIteration = 40000;
DataSetUsed = ['Patients40processedN4v2Normalized_' num2str(experimentIteration)];
%%

% Levels for beAware (modelIteration == 40000)
beAwareNotificationLevel = 0.7;
beAwareWarnLevel = 0.1;

%%
for modelIteration = [40000]
    
    % What echo to use (not really used)
    echo = 1;
    % What radius (mm) to use for original segmentation
    radiusSphere = 9;
    % What radius (mm) to use for kernel in convolution
    kernelRadius = 9;
    % How many gold fiducial markers to allow
    nrFiducial = 3;
    % Determine to use probability map 1 or 2.
    % Map 1 = object low value, bg high.
    % Map 2 = object high value, bg low.
    % This code is written for map 2.
    probMapChoice = 2;
    % Get current dir
    currDir = pwd;
    
    % Ground truth segmentation dir
    dirGT = fullfile(currDir,['GT' num2str(radiusSphere)],DataSetUsed);
    % Patient image dir (not really used)
    dirImage = fullfile(currDir,['echo_' num2str(echo)],DataSetUsed);
    
    if contains(DataSetUsed,'TrainingData')
        % Patient original segmentation as outputed from Niftynet and
        % patient original probabilty map
        dirNiftynetSegm = ['D:\beAware\output_all_' num2str(experimentIteration) '_' num2str(modelIteration)];
        dirNiftynetProb = ['D:\beAware\output_all_prob_' num2str(experimentIteration) '_' num2str(modelIteration)];
        % Folder for output washed segmentations
        dirMatlabWashedSegm = fullfile(currDir,'MatlabWashedSegm',DataSetUsed,['iter_' num2str(modelIteration)]);
        dirResultOutput = fullfile(currDir,'ResultOutput');
        dirQAimg = fullfile(currDir,'QAimg',DataSetUsed,['iter_' num2str(modelIteration)]);
    else
        dirNiftynetSegm = fullfile(currDir,'NiftynetSegm',DataSetUsed);
        dirNiftynetProb = fullfile(currDir,'NiftynetProb',DataSetUsed);
        dirMatlabWashedSegm = fullfile(currDir,'MatlabWashedSegm',DataSetUsed);
        dirResultOutput = fullfile(currDir,'ResultOutput');
        dirQAimg = fullfile(currDir,'QAimg',DataSetUsed);
    end
    
    % Expected resolution of pixels in mm for the data
    resRow = 0.4688;
    resCol = 0.4688;
    resSlice = 2.8;
    
    % For QA purposes
    QAImgOn = 0;
    pmSlices = 3;
    pauseTime = 0.1;
    QAGeomOn = 1;
    distCountThrehold = 1000000;
    
    % Be aware flag option
    beAwareFlag = 1;
    
    %% LOOP OVER ALL PATIENTS
    % Preallocate variable to be used later
    geom.DiffAbsAll = [];
    geom.DiffRowAll = [];
    geom.DiffColAll = [];
    geom.DiffSliceAll = [];
    geom.DiceAll = [];
    geom.beAwareScoreAll = [];
    % Get directory listing of subjects data
    % What folder is of interest for listing
    folderInterest = dirNiftynetSegm; % Original Niftynet segmentations
    fileNameSubjects = dir(folderInterest);
    % Remove . and ..
    fileNameSubjects=fileNameSubjects(~ismember({fileNameSubjects.name},{'.','..'}));
    
    % Start patient loop
    % Start on 2 for MR-PROTECT data.
    for i = 2:size(fileNameSubjects,1)
        % i = 1:size(fileNameSubjects,1)
        % Start clock
        tic
        %% READ PATIENT DATA
        % Split file name to parts
        splitPatNameString = strsplit(fileNameSubjects(i).name,'__');
        % Get only first part of file name (=patient name)
        currPatName = splitPatNameString{1};
        
        %if strcmp(currPatName,'Pat28') ~= 1
        %   continue
        % end
        
       
        if contains(DataSetUsed, 'TrainingData')
            % Make exclusion for nrFiducial if matching these patients
            switch currPatName
                case 'PatXXX'
                    nrFiducial = 2;
                case 'PatXXX'
                    nrFiducial = 2;
                case 'PatXXX'
                    nrFiducial = 2;
                case 'PatXXX'
                    nrFiducial = 2;
                case 'PatXXX'
                    nrFiducial = 2;
                case 'PatXXX'
                    nrFiducial = 2;
                case 'PatXXX'
                    nrFiducial = 2;
                case 'PatXXX'
                    nrFiducial = 2;
                case 'PatXXX'
                    nrFiducial = 2;
                case 'PatXXX'
                    nrFiducial = 2;
                otherwise
                    nrFiducial = 3;
            end
        end
        
        % Display patient name and current object in console
        disp([num2str(currPatName) ' object ' num2str(i) '/' num2str(size(fileNameSubjects,1))])
        disp(['Assuming ' num2str(nrFiducial) ' fiducials'])
        % Get patient ground truth segmentation path
        currGTPath = fullfile(dirGT,[currPatName '_coords.nii.gz']);
        % Get patient image path
        currImgPath = fullfile(dirImage,[currPatName '_echo-' num2str(echo) '.nii.gz']) ;
        % Get patient original segmentation path
        currNiftynetSegmPath = fullfile(dirNiftynetSegm,[currPatName '__niftynet_out.nii.gz']);
        % Get patient original probability map path
        currNiftynetProbPath = fullfile(dirNiftynetProb,[currPatName '__niftynet_out.nii.gz']);
        % Define patient new segmentation path
        currMatlabWashedSegmPath = fullfile(dirMatlabWashedSegm,[currPatName '__Matlab_out.nii.gz']);
        
        % Read patient GT
        currGT = single(niftiread(currGTPath));
        % Read patient volume and info
        % currImg = single(niftiread(currImgPath));
        % currImgInfo = niftiinfo(currImgPath);
        % Read patient original Niftynet segmentation and info
        currNiftynetSegm = single(niftiread(currNiftynetSegmPath));
        currNiftynetSegmInfo = niftiinfo(currNiftynetSegmPath);
        % Read Niftynet probability map
        currNiftynetProb = single(niftiread(currNiftynetProbPath));
        % It contains 5 dimensions, 3 spatial, 1 empty, and the last one containting
        % two types of probability maps
        % Make sure chosen probability map always has low background signal
        if sum(sum(sum(currNiftynetProb(:,:,:,1,1)))) < sum(sum(sum(currNiftynetProb(:,:,:,1,2))))
            error('Inconsistant NiftyNet proability map values were found')
        end
        
        
        %%  CREATE SPERE KERNEL
        % Define a point in the middle of the current image
        CrSpRow = round(size(currNiftynetSegm,1)/2);
        CrSpCol = round(size(currNiftynetSegm,2)/2);
        CrSpSlice = round(size(currNiftynetSegm,3)/2);
        % Create one sphere in that point on an empty 3D matrix
        [sampleSphereKernel,~] = createSphericalMask(currNiftynetSegm,[resRow resCol resSlice],kernelRadius,CrSpRow,CrSpCol,CrSpSlice,1);
        % Isolate sphere kernel whithout large background
        sphereKernel = regionprops(sampleSphereKernel, 'FilledImage');
        sphereKernel = sphereKernel.FilledImage;
        
        % Check that size of kernel is reasonable
        if size(sphereKernel,1) * resRow -2 > 2*kernelRadius
            error('Something is wrong with kernel size')
        end
        
        if size(sphereKernel,2) * resCol -2 > 2*kernelRadius
            error('Something is wrong with kernel size')
        end
        
        % Check symmetry of kernel
        if size(sphereKernel,1) ~= size(sphereKernel,2)
            warning('Sphere kernel is assymetric')
        end
        
        %% CONVOLUTION
        % Extract probability map
        currProbMap = currNiftynetProb(:,:,:,1,probMapChoice);
        % Convolve probability map with kernel and return same size as map
        currProbMapConv = convn(currProbMap,sphereKernel,'same');
        
        %% FIND PEAKS AND CALCULATE MAXIMUM (CRITICL STEP)
        % Number of fiducials are inserted to get number of peaks to output
        % This code contains exceptions to certain patients
        [rowMaxProb,colMaxProb,sliceMaxProb] = myPeakFinder(currPatName,currProbMap,currProbMapConv,nrFiducial,'probability',DataSetUsed);
        
        %% CREATE NEW MASK
        % Insert spheres at the determined locations (where probability were largest),
        % these should be same size as original Niftynet segmentation, use radiusSphere.
        [currMatlabWashedSegm, currMatlabWashedSegmInd] = createSphericalMask(currNiftynetSegm,[resRow resCol resSlice],radiusSphere,rowMaxProb,colMaxProb,sliceMaxProb,nrFiducial);
        % Write new Nifty segmentation file
        % Do not add header, there were problems with singleton dimensions.
        % The are expected in the header but Matlab can not produce them
        % niftiwrite(currOutSegm,currNewSegmPath,currNiftynetSegmInfo,'Compressed',true)
        niftiwrite(currMatlabWashedSegm,currMatlabWashedSegmPath,'Compressed',true)
        
        %% QA SECTION
        if QAImgOn
            run('QAImg.m')
        end
        
        if QAGeomOn
            
            %% FOR GEOMETRY CHECK BETWEEN RESULTS AND GT
            % Create a kernel with size of GT radius
            % Create one sphere in a point on an empty 3D matrix
            sampleGTKernel = createSphericalMask(currGT,[resRow resCol resSlice],radiusSphere,CrSpRow,CrSpCol,CrSpSlice,1);
            % Isolate GT kernel whithout large background
            GTKernel = regionprops(sampleGTKernel, 'FilledImage');
            GTKernel = GTKernel.FilledImage;
            
            %% These steps are not needed anymore for GT as the GT coordinates are assigned manually in myPeakFinder
            % Convolve GT with this kernel
            currGTConv = convn(currGT,GTKernel,'same');
            % Find peaks and get coordinates for maximum signal
            [rowMaxGT,colMaxGT,sliceMaxGT] = myPeakFinder(currPatName,currGT,currGTConv,nrFiducial,'GT',DataSetUsed);
            %%             
            
            % I value is not NaN add it to statistics
            if (sum(isnan(rowMaxGT)) + sum(isnan(colMaxGT)) + sum(isnan(sliceMaxGT)) == 0)
                % Calculate distance difference between probability peaks and GT peaks
                % Do this for every patient, measure it in mm.
                % An exception for patent 20 in the MR-PROTECT dataset had
                % to be done, beacuse of failed sorting, see code. 
                [geom.Diff{i}, geom.DiffAbs{i}, geom.DiffAbsPatientMean(i)] = QAGeom([rowMaxGT,colMaxGT,sliceMaxGT], [rowMaxProb,colMaxProb,sliceMaxProb], [resRow,resCol,resSlice], currPatName, DataSetUsed);
                % Collect all distance differences between all object centerpoints
                % Get current copy to matrix
                currGeomDiff = cell2mat(geom.Diff(i));
                % Distance in row direction
                geom.DiffRowAll = [geom.DiffRowAll currGeomDiff(:,1)'];
                % Distance in column direction
                geom.DiffColAll = [geom.DiffColAll currGeomDiff(:,2)'];
                % Distance in slice direction
                geom.DiffSliceAll = [geom.DiffSliceAll currGeomDiff(:,3)'];
                % Absolute distance
                geom.DiffAbsAll = [geom.DiffAbsAll cell2mat(geom.DiffAbs(i))'];
                % Calculate DICE score
                geom.Dice = dice(double(currMatlabWashedSegm),double(currGT));
                disp(['DICE for patient is ' num2str(geom.Dice)])
                geom.DiceAll = [geom.DiceAll geom.Dice];
            end
            % To show DICE for excluded patients (not saved)
            % excludedDICE = dice(double(currMatlabWashedSegm),double(currGT));
            % disp(['DICE for patient is ' num2str(excludedDICE)])
            
        end
        
        %% Be aware check section
        if beAwareFlag
            [beAwareScore] = beAwareMonitor(currPatName,currProbMap,currProbMapConv,currMatlabWashedSegm,currMatlabWashedSegmInd,nrFiducial,'probability',DataSetUsed);
            disp(['beAwaware score ' num2str(beAwareScore)])
            % Save beAware value
            geom.beAwareScoreAll = [geom.beAwareScoreAll beAwareScore];
            % Check if nere is need for notification or warning
            % if containts (DataSetUsed, 'Patients40processedN4v2Normalized') 
            if contains(DataSetUsed, 'Patients40processedN4v2Normalized')
                if beAwareScore <= beAwareNotificationLevel && beAwareScore > beAwareWarnLevel
                    disp('Please be aware that the produced results might be uncertain and must be manually checked')
                end
                
                if beAwareScore <= beAwareWarnLevel
                    disp('Please be aware that the produced results most probable contains at least 1 false fiducial and must be discarded')
                end
            end
        end
                
        %% Stop clock
        toc
        % Display distance
        disp(' ')
        % End patient loop
    end
    
    if QAGeomOn
        disp(' ')
        % Display mean value for all markers that deviates less than distCountThrehold
        disp(['Mean absolute deviation for all markers were ' num2str(mean(geom.DiffAbsAll(geom.DiffAbsAll<distCountThrehold))) ' mm'])
        disp(['STD absolute deviation for all markers were ' num2str(std(geom.DiffAbsAll(geom.DiffAbsAll<distCountThrehold))) ' mm'])
        disp(['Median absolute deviation for all markers were ' num2str(median(geom.DiffAbsAll(geom.DiffAbsAll<distCountThrehold))) ' mm'])
        disp(['Min absolute deviation for all markers were ' num2str(min(geom.DiffAbsAll(geom.DiffAbsAll<distCountThrehold))) ' mm'])
        disp(['Max absolute deviation for all markers were ' num2str(max(geom.DiffAbsAll(geom.DiffAbsAll<distCountThrehold))) ' mm'])
        disp(' ')
        disp(['Mean deviation in row were ' num2str(mean(geom.DiffRowAll(geom.DiffRowAll<distCountThrehold))) ' mm'])
        disp(['STD in row were ' num2str(std(geom.DiffRowAll(geom.DiffRowAll<distCountThrehold))) ' mm'])
        disp(['Median deviation in row were ' num2str(median(geom.DiffRowAll(geom.DiffRowAll<distCountThrehold))) ' mm'])
        disp(['Min deviation in row were ' num2str(min(geom.DiffRowAll(geom.DiffRowAll<distCountThrehold))) ' mm'])
        disp(['Max deviation in row were ' num2str(max(geom.DiffRowAll(geom.DiffRowAll<distCountThrehold))) ' mm'])
        disp(' ')
        disp(['Mean deviation in column were ' num2str(mean(geom.DiffColAll(geom.DiffColAll<distCountThrehold))) ' mm'])
        disp(['STD in column were ' num2str(std(geom.DiffColAll(geom.DiffColAll<distCountThrehold))) ' mm'])
        disp(['Median deviation in column were ' num2str(median(geom.DiffColAll(geom.DiffColAll<distCountThrehold))) ' mm'])
        disp(['Min deviation in column were ' num2str(min(geom.DiffColAll(geom.DiffColAll<distCountThrehold))) ' mm'])
        disp(['Max deviation in column were ' num2str(max(geom.DiffColAll(geom.DiffColAll<distCountThrehold))) ' mm'])
        disp(' ')
        disp(['Mean deviation in slice were ' num2str(mean(geom.DiffSliceAll(geom.DiffSliceAll<distCountThrehold))) ' mm'])
        disp(['STD in slice were ' num2str(std(geom.DiffSliceAll(geom.DiffSliceAll<distCountThrehold))) ' mm'])
        disp(['Median deviation in slice were ' num2str(median(geom.DiffSliceAll(geom.DiffSliceAll<distCountThrehold))) ' mm'])
        disp(['Min deviation in slice were ' num2str(min(geom.DiffSliceAll(geom.DiffSliceAll<distCountThrehold))) ' mm'])
        disp(['Max deviation in slice were ' num2str(max(geom.DiffSliceAll(geom.DiffSliceAll<distCountThrehold))) ' mm'])
        % DICE
        disp(' ')
        disp(['Mean DICE for all patients were ' num2str(mean(geom.DiceAll))])
        disp(['STD DICE for all patients were ' num2str(std(geom.DiceAll))])
        disp(['Median DICE for all patients were ' num2str(median(geom.DiceAll))])
        disp(['Min DICE for all patients were ' num2str(min(geom.DiceAll))])
        disp(['Max DICE for all patients were ' num2str(max(geom.DiceAll))])
        
        %% SAVE DATA TO MAT FILE
        save(fullfile(dirResultOutput,['save_geom_' num2str(DataSetUsed) '_kernelRadius_' num2str(kernelRadius) '_expIter_' num2str(experimentIteration) '_modelIter_' num2str(modelIteration)]),'geom')
        
        %% DISPLAY HISTOGRAM DATA
        figure
        histogram(geom.DiffRowAll(geom.DiffAbsAll<distCountThrehold))
        title('Difference in Row (mm)')
        saveas(gcf,fullfile(dirResultOutput,['Diff_Row_' num2str(DataSetUsed) '_kernelRadius_' num2str(kernelRadius) '_expIter_' num2str(experimentIteration) '_modelIter_' num2str(modelIteration) '.png']))
        figure
        histogram(geom.DiffColAll(geom.DiffAbsAll<distCountThrehold))
        title('Difference in Col (mm)')
        saveas(gcf,fullfile(dirResultOutput,['Diff_Col_' num2str(DataSetUsed) '_kernelRadius_' num2str(kernelRadius) '_expIter_' num2str(experimentIteration) '_modelIter_' num2str(modelIteration) '.png']))
        figure
        histogram(geom.DiffSliceAll(geom.DiffAbsAll<distCountThrehold))
        title('Difference in Slice (mm)')
        saveas(gcf,fullfile(dirResultOutput,['Diff_Slice_' num2str(DataSetUsed) '_kernelRadius_' num2str(kernelRadius) '_expIter_' num2str(experimentIteration) '_modelIter_' num2str(modelIteration) '.png']))
        figure
        histogram(geom.DiffAbsAll(geom.DiffAbsAll<distCountThrehold))
        title('Absolute difference (mm)')
        saveas(gcf,fullfile(dirResultOutput,['Diff_abs_' num2str(DataSetUsed) '_kernelRadius_' num2str(kernelRadius) '_expIter_' num2str(experimentIteration) '_modelIter_' num2str(modelIteration) '.png']))
        figure
        histogram(geom.DiffAbsPatientMean(geom.DiffAbsPatientMean<distCountThrehold))
        title('Mean absolute beteen patients (mm)')
        saveas(gcf,fullfile(dirResultOutput,['Mean absolute beteen patients_' num2str(DataSetUsed) '_kernelRadius_' num2str(kernelRadius) '_expIter_' num2str(experimentIteration) '_modelIter_' num2str(modelIteration) '.png']))
        
    end
    
    
    %%
    if beAwareFlag
        if contains(DataSetUsed, 'Patients40processedN4v2Normalized')
            
        else
            figure; plot(geom.DiceAll, (geom.beAwareScoreAll),'o')
            title('be Aware score vs DICE')
            xlabel('DICE')
            ylabel('be Aware Score')
            saveas(gcf,fullfile(dirResultOutput,['beAware_' num2str(DataSetUsed) '_kernelRadius_' num2str(kernelRadius) '_expIter_' num2str(experimentIteration) '_modelIter_' num2str(modelIteration) '.png']))
        end
    end
    %%
    % End model iteration loop
end

%% END OF FILE

