function [rowMax,colMax,sliceMax] = myPeakFinder(PatName,inputVolume,inputVolumeConv,nrObject,description,DataSetUsed)
%% FIND PEAKS AND GET MAXIMUM (CRITICL STEP)
% Find all peaks within the input image volume.
% Can be used for probability map or any convoluted map.
% Uses connectivety of 26 as default.
% Searches the whole image volume.
peaksLogic = imregionalmax(inputVolumeConv);
disp([num2str(sum(peaksLogic(:))) ' ' description ' peaks found'])
% Multiplication between the peaklogic matrix and input volume
valuePeaks = inputVolumeConv .* peaksLogic;
% Get the index of the nrFid number of largest probability peaks
[~,index] = maxk(valuePeaks(:),nrObject);
% Convert back to matrix coordinates
[rowMax,colMax,sliceMax] = ind2sub(size(inputVolumeConv),index);

% QA check and manuel definition for GT
if strcmp(description,'GT')
    if sum(peaksLogic(:)) > nrObject
        disp('Found more peaks in GT than number of fiducials')
        % No specific action here, but GT are defined in the list bellow for
        % MR-PROTECT data
    end
    switch DataSetUsed
        case 'Patients40processedN4v2Normalized_145'
            switch PatName
                case 'PatXXX' % Excluded because of 4 fiducials.
                    % Here is 3/4 fiducial GT
                    %                     rowMax = [272  238  274]';
                    %                     colMax = [256  239  262]';
                    %                     sliceMax = [14  16  18]';
                    rowMax = NaN;
                    colMax = NaN;
                    sliceMax = NaN;
                    disp(['Skipping ' num2str(PatName) ' for geometry, not included in study'])
                case 'PatXXX'
                    rowMax = [268  230  286]';
                    colMax = [274  257  255]';
                    sliceMax = [17  19  23]';
                case 'PatXXX'
                    rowMax = [270  231  291]';
                    colMax = [247  268  236]';
                    sliceMax = [13  16  21]';
                case 'PatXXX'
                    rowMax = [265  229  282]';
                    colMax = [265  276  239]';
                    sliceMax = [10  13  16]';
                case 'PatXXX'
                    rowMax = [282  238  288]';
                    colMax = [238  212  210]';
                    sliceMax = [16  19  21]';
                case 'PatXXX'
                    rowMax = [264  252  280]';
                    colMax = [275  288  269]';
                    sliceMax = [13  15  19]';
                case 'PatXXX'
                    rowMax = [269  243  298]';
                    colMax = [268  293  274]';
                    sliceMax = [12  16  20]';
                case 'PatXXX'
                    rowMax = [263  234  278]';
                    colMax = [269  297  254]';
                    sliceMax = [12  16  20]';
                case 'PatXXX'
                    rowMax = [278  223  278]';
                    colMax = [241  254  230]';
                    sliceMax = [15  19  23]';
                case 'PatXXX'
                    rowMax = [272  227  289]';
                    colMax = [253  286  262]';
                    sliceMax = [13  15  19]';
                case 'PatXXX'
                    rowMax = [266  227  289]';
                    colMax = [239  227  213]';
                    sliceMax = [10  18  21]';
                case 'PatXXX'
                    rowMax = [284  213  275]';
                    colMax = [277  269  271]';
                    sliceMax = [11  17  19]';
                case 'PatXXX'
                    rowMax = [280  217  273]';
                    colMax = [297  269  238]';
                    sliceMax = [16  18  21]';
                case 'PatXXX'
                    rowMax = [278  222  286]';
                    colMax = [290  277  258]';
                    sliceMax = [15  18  21]';
                case 'PatXXX'
                    rowMax = [285  286  228]';
                    colMax = [285  241  272]';
                    sliceMax = [13  18  18]';
                case 'PatXXX' % Failed in detection of correct fiducials
                    %                     rowMax = [271  234  277]';
                    %                     colMax = [278  275  240]';
                    %                     sliceMax = [16  18  19]';
                    rowMax = NaN;
                    colMax = NaN;
                    sliceMax = NaN;
                    disp(['Skipping ' num2str(PatName) ' for geometry because of detection failure'])
                case 'PatXXX'
                    rowMax = [231  304  292]';
                    colMax = [273  255  279]';
                    sliceMax = [13  15  15]';
                case 'PatXXX'
                    rowMax = [234  283  300]';
                    colMax = [263  277  269]';
                    sliceMax = [16  17  21]';
                case 'PatXXX'
                    rowMax = [218  276  282]';
                    colMax = [236  272  223]';
                    sliceMax = [17  18  20]';
                case 'PatXXX'
                    rowMax = [220  285  273]';
                    colMax = [254  271  243]';
                    sliceMax = [16  16  18]';
                case 'PatXXX'
                    rowMax = [291  236  281]';
                    colMax = [257  236  212]';
                    sliceMax = [14  20  22]';
                case 'PatXXX'
                    rowMax = [287  218  283]';
                    colMax = [250  260  219]';
                    sliceMax = [15  19  22]';
                case 'PatXXX'
                    rowMax = [276  235  295]';
                    colMax = [277  269  262]';
                    sliceMax = [13  14  18]';
                case 'PatXXX'
                    rowMax = [288  238  295]';
                    colMax = [273  269  255]';
                    sliceMax = [12  16  17]';
                case 'PatXXX'
                    rowMax = [221  280  272]';
                    colMax = [239  262  227]';
                    sliceMax = [19  20  22]';
                case 'PatXXX'
                    rowMax = [292  223  273]';
                    colMax = [286  268  266]';
                    sliceMax = [13  18  24]';
                case 'PatXXX'
                    rowMax = [230  275  287]';
                    colMax = [279  296  261]';
                    sliceMax = [15  15  16]';
                case 'PatXXX' % Failed in detection of correct fiducials
                    %                     rowMax = [237  289  285]';
                    %                     colMax = [265  280  260]';
                    %                     sliceMax = [19  19  21]';
                    rowMax = NaN;
                    colMax = NaN;
                    sliceMax = NaN;
                    disp(['Skipping ' num2str(PatName) ' for geometry because of detection failure'])
                case 'PatXXX'
                    rowMax = [301  210  268]';
                    colMax = [302  293  271]';
                    sliceMax = [14  15  19]';
                case 'PatXXX'
                    rowMax = [285  228  281]';
                    colMax = [279  273  248]';
                    sliceMax = [12  18  19]';
                case 'PatXXX'
                    rowMax = [292  218  270]';
                    colMax = [268  262  242]';
                    sliceMax = [15  18  20]';
                case 'PatXXX'
                    rowMax = [279  224  274]';
                    colMax = [259  250  239]';
                    sliceMax = [13  18  20]';
                case 'PatXXX'
                    rowMax = [266  226  269]';
                    colMax = [287  274  258]';
                    sliceMax = [13  17  20]';
                case 'PatXXX'
                    rowMax = [270  274  244]';
                    colMax = [307  271  305]';
                    sliceMax = [15  18  19]';
                case 'PatXXX'
                    rowMax = [294  218  278]';
                    colMax = [259  260  246]';
                    sliceMax = [13  20  24]';
                case 'PatXXX'
                    rowMax = [276  229  273]';
                    colMax = [278  252  229]';
                    sliceMax = [17  20  21]';
                case 'PatXXX'
                    rowMax = [286  276  225]';
                    colMax = [284  235  272]';
                    sliceMax = [15  18  18]';
                case 'PatXXX'
                    rowMax = [282  279  224]';
                    colMax = [282  235  258]';
                    sliceMax = [16  17  17]';
                case 'PatXXX'
                    rowMax = [286  215  278]';
                    colMax = [337  307  271]';
                    sliceMax = [14  15  17]';
                case 'PatXXX'
                    rowMax = [281  228  280]';
                    colMax = [265  243  238]';
                    sliceMax = [14  16  17]';
                    
            end
            
        case 'Patients40processedN4v2Normalized_147'
            switch PatName
                case 'PatXXX' % Excluded because of 4 fiducials.
                    % Here is 3/4 fiducial GT
                    %                     rowMax = [272  238  274]';
                    %                     colMax = [256  239  262]';
                    %                     sliceMax = [14  16  18]';
                    rowMax = NaN;
                    colMax = NaN;
                    sliceMax = NaN;
                    disp(['Skipping ' num2str(PatName) ' for geometry, not included in study'])
                case 'PatXXX'
                    rowMax = [268  230  286]';
                    colMax = [274  257  255]';
                    sliceMax = [17  19  23]';
                case 'PatXXX'
                    rowMax = [270  231  291]';
                    colMax = [247  268  236]';
                    sliceMax = [13  16  21]';
                case 'PatXXX'
                    rowMax = [265  229  282]';
                    colMax = [265  276  239]';
                    sliceMax = [10  13  16]';
                case 'PatXXX'
                    rowMax = [282  238  288]';
                    colMax = [238  212  210]';
                    sliceMax = [16  19  21]';
                case 'PatXXX'
                    rowMax = [264  252  280]';
                    colMax = [275  288  269]';
                    sliceMax = [13  15  19]';
                case 'PatXXX'
                    rowMax = [269  243  298]';
                    colMax = [268  293  274]';
                    sliceMax = [12  16  20]';
                case 'PatXXX'
                    rowMax = [263  234  278]';
                    colMax = [269  297  254]';
                    sliceMax = [12  16  20]';
                case 'PatXXX'
                    rowMax = [278  223  278]';
                    colMax = [241  254  230]';
                    sliceMax = [15  19  23]';
                case 'PatXXX'
                    rowMax = [272  227  289]';
                    colMax = [253  286  262]';
                    sliceMax = [13  15  19]';
                case 'PatXXX'
                    rowMax = [266  227  289]';
                    colMax = [239  227  213]';
                    sliceMax = [10  18  21]';
                case 'PatXXX'
                    rowMax = [284  213  275]';
                    colMax = [277  269  271]';
                    sliceMax = [11  17  19]';
                case 'PatXXX'
                    rowMax = [280  217  273]';
                    colMax = [297  269  238]';
                    sliceMax = [16  18  21]';
                case 'PatXXX'
                    % rowMax = [278  222  286]';
                    % colMax = [290  277  258]';
                    % sliceMax = [15  18  21]';
                    rowMax = NaN;
                    colMax = NaN;
                    sliceMax = NaN;
                    disp(['Skipping ' num2str(PatName) ' for geometry because of detection failure'])
                case 'PatXXX'
                    rowMax = [285  286  228]';
                    colMax = [285  241  272]';
                    sliceMax = [13  18  18]';
                case 'PatXXX' % Failed in detection of correct fiducials
                    %                     rowMax = [271  234  277]';
                    %                     colMax = [278  275  240]';
                    %                     sliceMax = [16  18  19]';
                    rowMax = NaN;
                    colMax = NaN;
                    sliceMax = NaN;
                    disp(['Skipping ' num2str(PatName) ' for geometry because of detection failure'])
                case 'PatXXX'
                    rowMax = [231  304  292]';
                    colMax = [273  255  279]';
                    sliceMax = [13  15  15]';
                case 'PatXXX'
                    rowMax = [234  283  300]';
                    colMax = [263  277  269]';
                    sliceMax = [16  17  21]';
                case 'PatXXX'
                    rowMax = [218  276  282]';
                    colMax = [236  272  223]';
                    sliceMax = [17  18  20]';
                case 'PatXXX'
                    rowMax = [220  285  273]';
                    colMax = [254  271  243]';
                    sliceMax = [16  16  18]';
                case 'PatXXX'
                    rowMax = [291  236  281]';
                    colMax = [257  236  212]';
                    sliceMax = [14  20  22]';
                case 'PatXXX'
                    rowMax = [287  218  283]';
                    colMax = [250  260  219]';
                    sliceMax = [15  19  22]';
                case 'PatXXX'
                    rowMax = [276  235  295]';
                    colMax = [277  269  262]';
                    sliceMax = [13  14  18]';
                case 'PatXXX'
                    rowMax = [288  238  295]';
                    colMax = [273  269  255]';
                    sliceMax = [12  16  17]';
                case 'PatXXX'
                    rowMax = [221  280  272]';
                    colMax = [239  262  227]';
                    sliceMax = [19  20  22]';
                case 'PatXXX'
                    rowMax = [292  223  273]';
                    colMax = [286  268  266]';
                    sliceMax = [13  18  24]';
                case 'PatXXX'
                    rowMax = [230  275  287]';
                    colMax = [279  296  261]';
                    sliceMax = [15  15  16]';
                case 'PatXXX' % Failed in detection of correct fiducials
                    %                     rowMax = [237  289  285]';
                    %                     colMax = [265  280  260]';
                    %                     sliceMax = [19  19  21]';
                    rowMax = NaN;
                    colMax = NaN;
                    sliceMax = NaN;
                    disp(['Skipping ' num2str(PatName) ' for geometry because of detection failure'])
                case 'PatXXX'
                    rowMax = [301  210  268]';
                    colMax = [302  293  271]';
                    sliceMax = [14  15  19]';
                case 'PatXXX'
                    rowMax = [285  228  281]';
                    colMax = [279  273  248]';
                    sliceMax = [12  18  19]';
                case 'PatXXX'
                    rowMax = [292  218  270]';
                    colMax = [268  262  242]';
                    sliceMax = [15  18  20]';
                case 'PatXXX'
                    rowMax = [279  224  274]';
                    colMax = [259  250  239]';
                    sliceMax = [13  18  20]';
                case 'PatXXX'
                    rowMax = [266  226  269]';
                    colMax = [287  274  258]';
                    sliceMax = [13  17  20]';
                case 'PatXXX'
                    rowMax = [270  274  244]';
                    colMax = [307  271  305]';
                    sliceMax = [15  18  19]';
                case 'PatXXX'
                    rowMax = [294  218  278]';
                    colMax = [259  260  246]';
                    sliceMax = [13  20  24]';
                case 'PatXXX'
                    rowMax = [276  229  273]';
                    colMax = [278  252  229]';
                    sliceMax = [17  20  21]';
                case 'PatXXX'
                    rowMax = [286  276  225]';
                    colMax = [284  235  272]';
                    sliceMax = [15  18  18]';
                case 'PatXXX'
                    rowMax = [282  279  224]';
                    colMax = [282  235  258]';
                    sliceMax = [16  17  17]';
                case 'PatXXX'
                    rowMax = [286  215  278]';
                    colMax = [337  307  271]';
                    sliceMax = [14  15  17]';
                case 'PatXXX'
                    rowMax = [281  228  280]';
                    colMax = [265  243  238]';
                    sliceMax = [14  16  17]';
                    
            end
            
        case 'Training Data'
            % NO ACTION YET
            switch PatName
            end
    end
end


%%

end




