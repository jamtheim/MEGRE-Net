function [outMaskAllinOne, outMaskInd] = createSphericalMask(inputGeometry,resolution,radius,rowPoints,colPoints,slicePoints,numberSpheres)
% Creates a spherical mask with value one in an empty 3D matrix.
% Several spheres can be created.
% Also outputs individual masks for the different spheres. 

% Get resulution
resRow = resolution(1,1);
resColumn  = resolution(1,2);
resSlice = resolution(1,3);
% Quality check of data
if size(slicePoints,1) ~= numberSpheres
    error('Amount of points inputed is not the same as number of spheres defined')
end

% Allocate matrix with zeros
outMaskAllinOne = zeros(size(inputGeometry),'single');
outMaskInd = zeros([size(inputGeometry),numberSpheres],'single');

% Loop through all points
for currSphere = 1:numberSpheres
    % Slice loop
    for currentSlice = 1:size(outMaskAllinOne,3)
        % For row
        for currentRow = 1:size(outMaskAllinOne,1)
            % For column
            for currentColumn = 1:size(outMaskAllinOne,2)
                % Calculate distance to defined point
                currentDistance = sqrt(((rowPoints(currSphere) - currentRow)*resRow)^2 + ((colPoints(currSphere) - currentColumn)*resColumn)^2 + ((slicePoints(currSphere) - currentSlice)*resSlice)^2);
                if currentDistance <= radius
                    % Set to value 1 in mask space
                    outMaskAllinOne(currentRow, currentColumn, currentSlice)=1;
                    outMaskInd(currentRow, currentColumn, currentSlice, currSphere)=1;
                end
            end
        end
    end
end

% End function
end

