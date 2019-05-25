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
p2Fs = 20;
p2Fs_2 = 5;
x = 1;
y = 1;
z = 1;
e = 1;
f = 1;
g = 1;
for a = 1:length(animalIDs)
    animalID = animalIDs{a,1};
    for b = 1:length(ComparisonData.(animalID).WhiskEvokedAvgs.vesselData{1,1})
        try
            whiskDataC1_1(x,:) = ComparisonData.(animalID).WhiskEvokedAvgs.vesselData{1,1}{b,1};
            vID = join([string(animalID) string(ComparisonData.(animalID).WhiskEvokedAvgs.vesselIDs{b,1})]);
            vIDs1{x,1} = strrep(vID, ' ', '');
            x = x + 1;
        catch
            whiskDataC1_2(e,:) = ComparisonData.(animalID).WhiskEvokedAvgs.vesselData{1,1}{b,1};
            vID = join([string(animalID) string(ComparisonData.(animalID).WhiskEvokedAvgs.vesselIDs{b,1})]);
            vIDs2{e,1} = strrep(vID, ' ', '');
            e = e + 1;
        end
    end
    
    for c = 1:length(ComparisonData.(animalID).WhiskEvokedAvgs.vesselData{2,1})
        try
            whiskDataC2_1(y,:) = ComparisonData.(animalID).WhiskEvokedAvgs.vesselData{2,1}{c,1};
            y = y + 1;
        catch
            whiskDataC2_2(f,:) = ComparisonData.(animalID).WhiskEvokedAvgs.vesselData{2,1}{c,1};
            f = f + 1;
        end
    end
    
    for d = 1:length(ComparisonData.(animalID).WhiskEvokedAvgs.vesselData{3,1})
        try
            whiskDataC3_1(z,:) = ComparisonData.(animalID).WhiskEvokedAvgs.vesselData{3,1}{d,1};
            z = z + 1;
        catch
            whiskDataC3_2(g,:) = ComparisonData.(animalID).WhiskEvokedAvgs.vesselData{3,1}{d,1};
            g = g + 1;
        end
    end
end

%%
for h = 1:size(whiskDataC1_1, 1)
    whiskDataC1_3(h,:) = resample(whiskDataC1_1(h,:), p2Fs_2, p2Fs);
    whiskDataC2_3(h,:) = resample(whiskDataC2_1(h,:), p2Fs_2, p2Fs);
    whiskDataC3_3(h,:) = resample(whiskDataC3_1(h,:), p2Fs_2, p2Fs);
end


%%
for i = 1:size(whiskDataC1_2, 1)
    whiskDataC1_3(x,:) = whiskDataC1_2(i,:);
    whiskDataC2_3(x,:) = whiskDataC2_2(i,:);
    whiskDataC3_3(x,:) = whiskDataC3_2(i,:); 
    vIDs1{x,1} = vIDs2{i,1};
    x = x + 1;
end


%%
timeVec = ((1:length(whiskDataC1_3))/p2Fs_2) - leadTime;
figure;
ax1 = subplot(1,3,1);
for x = 1:size(whiskDataC1_3, 1)
    plot(timeVec, whiskDataC1_3(x,:));
    hold on
end
title('Ind 0.5 to 2 seconds')
xlabel('Peri-whisk time (sec)')
ylabel('\Delta Diameter (%)')

ax2 = subplot(1,3,2);
for y = 1:size(whiskDataC2_3, 1)
    plot(timeVec, whiskDataC2_3(y,:));
    hold on
end
title('Ind 2 to 5 seconds')
xlabel('Peri-whisk time (sec)')
ylabel('\Delta Diameter (%)')

ax3 = subplot(1,3,3);
for z = 1:size(whiskDataC3_3, 1)
    plot(timeVec, whiskDataC3_3(z,:));
    hold on
end
title('Ind 5 to 10 seconds')
xlabel('Peri-whisk time (sec)')
ylabel('\Delta Diameter (%)')
legend(vIDs1)
linkaxes([ax1 ax2 ax3], 'xy')
pause(1)

end