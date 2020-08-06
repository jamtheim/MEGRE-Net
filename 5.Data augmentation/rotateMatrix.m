function [rotMatrix] = rotateMatrix(matrix,angle,type)
% Rotate the volume around the Z axis.
% Different settings if it is a volume or label matrix

if strcmp(type,'typeVolume')
    % Linear interpolation to keep pixel values within range.
    % Tricubic interpolation can produce pixel values outside the original range.
    rotMatrix = imrotate3(matrix,angle,[0 0 1],'linear','crop','FillValues',0);
    % nearest neighbour interpolation creates much smaller file sizes after compression. But as
    % data in uncompressed before processing in neural net, it should not matter. 
end

if strcmp(type,'typeLabel')
    % Must have nearest as all values must be 0 or 1 in LABEL
    rotMatrix = imrotate3(matrix,angle,[0 0 1],'nearest','crop','FillValues',0);
end

% Some quality check
% Size of matrixes
if size(matrix) ~= size(rotMatrix)
    error('Size is not the same in original and rotated VOLUME')
end
% Values in label matrix
if strcmp(type,'typeLabel')
    % Values in label, other than 0 or 1
    if ~isempty(find(rotMatrix>0 & rotMatrix <1))
        error('Value in LABEl is not 0 or 1')
    end
end

