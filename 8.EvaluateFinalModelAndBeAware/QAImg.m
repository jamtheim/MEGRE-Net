% Check if produced signal centers corresponds to ground truth.
% OK to use GT here for QA purposes
% Interesting to look at currProbMapConv and currNifynetSegm or currGT

%%
for j = min(sliceMaxProb)-pmSlices:max(sliceMaxProb)+pmSlices
    cNS = figure(1); imshow(currNiftynetSegm(:,:,j),[])
    drawnow
    pause(pauseTime)
    if  ismember(j,sliceMaxProb)
        index = find(j==sliceMaxProb);
        hold on
        plot(colMaxProb(index(:)),rowMaxProb(index(:)),'b*')
        drawnow
        pause(pauseTime)
        hold off
    end
    % Save figure
    saveas(cNS,fullfile(dirQAimg, [num2str(currPatName) '_aNiftySeg_Det_slice' num2str(j) '.png']))
    clf(cNS)
end
%%
% Compare final segmentation and its center point tomwards GT
%if strcmp(currPatName,'Pat09')
for j = min(sliceMaxProb)-pmSlices:max(sliceMaxProb)+pmSlices
    MvsGT = figure(2); imshowpair(currMatlabWashedSegm(:,:,j),currGT(:,:,j))
    drawnow
    pause(pauseTime)
    if  ismember(j,sliceMaxProb)
        index = find(j==sliceMaxProb);
        hold on
        plot(colMaxProb(index(:)),rowMaxProb(index(:)),'b*')
        drawnow
        pause(pauseTime)
        hold off
    end
    % Save figure
    saveas(MvsGT,fullfile(dirQAimg, [num2str(currPatName) '_bMat_GT_slice' num2str(j) '.png']))
    clf(cNS)
end
%%