function [diffMetric,diffMetricAbs,diffMetricAbsMean] = QAGeom(coordGT,coordMaxProb,resolution,patname,DataSetUsed)
%% Calculate difference between GT peaks and detected peaks

% Sort coordinates on distance from origo
% GT
% distGT = sqrt(coordGT(:,1).^2+coordGT(:,2).^2+coordGT(:,3).^2);
% [~,idDistGT] = sort(distGT);
% coordGT = coordGT(idDistGT,:);
% % MaxProb
% distMaxProb = sqrt(coordMaxProb(:,1).^2+coordMaxProb(:,2).^2+coordMaxProb(:,3).^2);
% [~,idDistMaxProb] = sort(distMaxProb);
% coordMaxProb = coordMaxProb(idDistMaxProb,:);


% Sort by slice in ascending order, if equal column, if equal row
[coordGT,idGT] = sortrows(coordGT, [3 2 1]);
% Make same operation for probability peaks
[coordMaxProb,idProb] = sortrows(coordMaxProb, [3 2 1]);

% Exception for patient20 in the MR-PROTECT dataset
if strcmp(patname,'PatXXX')
    if  coordGT == [220 254 16
            285 271 16
            273 243 18]
        coordGT = [285 271 16
            220 254 16
            273 243 18];
        disp('Sorting order for PatientXXX coordGT edited manually in QAGeom.m')
    end
    
end

% Correction for error in sorting
if strcmp(DataSetUsed,'Patients40processedN4v2Normalized_147')
    if strcmp(patname,'PatXXX')
       [coordMaxProb,idProb] = sortrows(coordMaxProb, [3 1 2]); 
    end
end


% Get components
rowMaxGTSorted = coordGT(:,1);
colMaxGTSorted = coordGT(:,2);
sliceMaxGTSorted = coordGT(:,3);
% Get components
rowMaxProbSorted= coordMaxProb(:,1);
colMaxProbSorted = coordMaxProb(:,2);
sliceMaxProbSorted = coordMaxProb(:,3);
% Get components for image resolution
resRow = resolution(1,1);
resCol  = resolution(1,2);
resSlice = resolution(1,3);



% Sort by ascending row value and correct order of corresponding column and
% slice. Better resolution than sorting in slice.
% [rowMaxGTSorted,idRowGT] = sort(rowMaxGT);
% colMaxGTSorted = colMaxGT(idRowGT,:);
% sliceMaxGTSorted = sliceMaxGT(idRowGT,:);

% Sort by ascending slice value and correct order of corresponding row and column
% [sliceMaxGTSorted,idSliceGT] = sort(sliceMaxGT);
% rowMaxGTSorted = rowMaxGT(idSliceGT,:);
% colMaxGTSorted = colMaxGT(idSliceGT,:);

% Make same operation for probability peaks
% [rowMaxProbSorted,idRowProb] = sort(rowMaxProb);
% colMaxProbSorted = colMaxProb(idRowProb,:);
% sliceMaxProbSorted = sliceMaxProb(idRowProb,:);

% Calculate difference in pixels for every coordinate for every marker(GT-predicted)
diffPix = [rowMaxGTSorted colMaxGTSorted sliceMaxGTSorted] - [rowMaxProbSorted colMaxProbSorted sliceMaxProbSorted];
% Calculate distance in mm
diffMetric = diffPix .* [resRow resCol resSlice];
% Get absolute distance for each marker
diffMetricAbs = sqrt(diffMetric(:,1).^2+diffMetric(:,2).^2+diffMetric(:,3).^2);
% Get mean distance for all markers per patient
diffMetricAbsMean = mean(diffMetricAbs);
diffMetricAbsMax = max(diffMetricAbs);
disp([num2str(diffMetricAbsMean) ' mm average deviation'])
disp([num2str(diffMetricAbsMax) ' mm max deviation'])
end
