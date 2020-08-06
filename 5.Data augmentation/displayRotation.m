function [] = displayRotation(volume, volumeRot, label, labelRot, patName, angle)
 % Display rotation for quality assurance

% Get slices where we have a label values = 1
i = 0;
for n = 1:size(label,3)
    if sum(sum(label(:,:,n))) > 0
        i = i + 1;
        index(i)= n;
    end
end

% Check second slice
slice = index(2);


% Add cross to labels
label(255:256,:,:) = 1; 
label(:,255:256,:) = 1; 
labelRot(255:256,:,:) = 1; 
labelRot(:,255:256,:) = 1; 

f = figure(1); 
subplot(2,2,1)
imshow(volume(:,:,slice)+1000*label(:,:,slice),[])
subplot(2,2,2)
imshow(volumeRot(:,:,slice)+1000*labelRot(:,:,slice),[])
subplot(2,2,3)
imshow(label(:,:,slice),[])
subplot(2,2,4)
imshow(labelRot(:,:,slice),[])
f.WindowState = 'maximized';
saveas(gcf,[num2str(patName) '_' num2str(angle) '.png'])

end

