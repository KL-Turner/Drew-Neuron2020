function SuppFigOne_SlowOscReview2019(ComparisonData)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: 
%________________________________________________________________________________________________________________________
%
%   Inputs: 
%
%   Outputs: 
%
%   Last Revised: March 22nd, 2019
%________________________________________________________________________________________________________________________

%%
animalIDs = fields(ComparisonData);
leadTime = 4;
x = 1;
y = 1;
z = 1;
for a = 1:length(animalIDs)
    animalID = animalIDs{a,1};
    for b = 1:length(ComparisonData.(animalID).WhiskEvokedAvgs.vesselData{1,1})
        whiskDataC1(x,:) = ComparisonData.(animalID).WhiskEvokedAvgs.vesselData{1,1}{b,1};
        vID = join([string(animalID) string(ComparisonData.(animalID).WhiskEvokedAvgs.vesselIDs{b,1})]);
        vIDs{x,1} = strrep(vID, ' ', '');
        x = x + 1;
    end
    
    for c = 1:length(ComparisonData.(animalID).WhiskEvokedAvgs.vesselData{2,1})
        whiskDataC2(y,:) = ComparisonData.(animalID).WhiskEvokedAvgs.vesselData{2,1}{c,1};
        y = y + 1;
    end
    
    for d = 1:length(ComparisonData.(animalID).WhiskEvokedAvgs.vesselData{3,1})
        whiskDataC3(z,:) = ComparisonData.(animalID).WhiskEvokedAvgs.vesselData{3,1}{d,1};
        z = z + 1;
    end
end

%%
timeVec = ((1:length(whiskDataC1))/p2Fs) - leadTime;
figure;
ax1 = subplot(1,3,1);
for x = 1:size(whiskDataC1, 1)
    plot(timeVec, whiskDataC1(x,:));
    hold on
end
title('Ind 0.5 to 2 seconds')
xlabel('Peri-whisk time (sec)')
ylabel('\Delta Diameter (%)')

ax2 = subplot(1,3,2);
for y = 1:size(whiskDataC2, 1)
    plot(timeVec, whiskDataC2(y,:));
    hold on
end
title('Ind 2 to 5 seconds')
xlabel('Peri-whisk time (sec)')
ylabel('\Delta Diameter (%)')

ax3 = subplot(1,3,3);
for z = 1:size(whiskDataC3, 1)
    plot(timeVec, whiskDataC3(z,:));
    hold on
end
title('Ind 5 to 10 seconds')
xlabel('Peri-whisk time (sec)')
ylabel('\Delta Diameter (%)')
legend(vIDs)
linkaxes([ax1 ax2 ax3], 'xy')
pause(1)

end