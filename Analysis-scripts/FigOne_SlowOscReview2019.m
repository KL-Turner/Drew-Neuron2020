function FigOne_SlowOscReview2019(ComparisonData)
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
    whiskLFPC1(:,:,a) = ComparisonData.(animalID).WhiskEvokedAvgs.LFP.S{1,1};
    whiskLFPC2(:,:,a) = ComparisonData.(animalID).WhiskEvokedAvgs.LFP.S{2,1};
    whiskLFPC3(:,:,a) = ComparisonData.(animalID).WhiskEvokedAvgs.LFP.S{3,1};
end

for h = 1:size(whiskDataC1_1, 1)
    whiskDataC1_3(h,:) = resample(whiskDataC1_1(h,:), p2Fs_2, p2Fs);
    whiskDataC2_3(h,:) = resample(whiskDataC2_1(h,:), p2Fs_2, p2Fs);
    whiskDataC3_3(h,:) = resample(whiskDataC3_1(h,:), p2Fs_2, p2Fs);
end

for i = 1:size(whiskDataC1_2, 1)
    whiskDataC1_3(x,:) = whiskDataC1_2(i,:);
    whiskDataC2_3(x,:) = whiskDataC2_2(i,:);
    whiskDataC3_3(x,:) = whiskDataC3_2(i,:);
    vIDs1{x,1} = vIDs2{i,1};
    x = x + 1;
end

T = ComparisonData.(animalID).WhiskEvokedAvgs.LFP.T{1,1};
F = ComparisonData.(animalID).WhiskEvokedAvgs.LFP.F{1,1};
whiskDataMeanC1 = mean(whiskDataC1_3,1);
whiskDataMeanC2 = mean(whiskDataC2_3,1);
whiskDataMeanC3 = mean(whiskDataC3_3,1);
whiskSTDC1 = std(whiskDataC1_3,1,1);
whiskSTDC2 = std(whiskDataC2_3,1,1);
whiskSTDC3 = std(whiskDataC3_3,1,1);
whiskLFPMeanC1 = mean(whiskLFPC1,3);
whiskLFPMeanC2 = mean(whiskLFPC2,3);
whiskLFPMeanC3 = mean(whiskLFPC3,3);

%%
timeVec = ((1:length(whiskDataMeanC1))/p2Fs_2) - leadTime;
figure;
ax1 = subplot(2,3,1);
plot(timeVec, whiskDataMeanC1, 'k', 'LineWidth', 2)
hold on
plot(timeVec, whiskDataMeanC1 + whiskSTDC1, 'Color', colors_SlowOscReview2019('ash grey'))
plot(timeVec, whiskDataMeanC1 - whiskSTDC1, 'Color', colors_SlowOscReview2019('ash grey'))
title('Mean 0.5 to 2')
xlabel('Peri-whisk time (sec)')
ylabel('\Delta Diameter (%)')

ax2 = subplot(2,3,2);
plot(timeVec, whiskDataMeanC2, 'k', 'LineWidth', 2)
hold on
plot(timeVec, whiskDataMeanC2 + whiskSTDC2, 'Color', colors_SlowOscReview2019('ash grey'))
plot(timeVec, whiskDataMeanC2 - whiskSTDC2, 'Color', colors_SlowOscReview2019('ash grey'))
title('Mean 2 to 5')
xlabel('Peri-whisk time (sec)')
ylabel('\Delta Diameter (%)')

ax3 = subplot(2,3,3);
plot(timeVec, whiskDataMeanC3, 'k', 'LineWidth', 2)
hold on
plot(timeVec, whiskDataMeanC3 + whiskSTDC3, 'Color', colors_SlowOscReview2019('ash grey'))
plot(timeVec, whiskDataMeanC3 - whiskSTDC3, 'Color', colors_SlowOscReview2019('ash grey'))
title('Mean 5 to 10')
xlabel('Peri-whisk time (sec)')
ylabel('\Delta Diameter (%)')
linkaxes([ax1 ax2 ax3], 'xy')

subplot(2,3,4);
imagesc(T,F,whiskLFPMeanC1);
axis xy
caxis([-.5 0.75])
ylim([1 100])
colormap parula
title('LFP 0.5 to 2 seconds')
ylabel('Frequency (Hz)')
xlabel('Peri-whisk time (sec)')

subplot(2,3,5);
imagesc(T,F,whiskLFPMeanC2);
axis xy
caxis([-.5 0.75])
ylim([1 100])
colormap parula
title('LFP 2 to 5 seconds')
ylabel('Frequency (Hz)')
xlabel('Peri-whisk time (sec)')

subplot(2,3,6);
imagesc(T,F,whiskLFPMeanC3);
axis xy
caxis([-.5 0.75])
ylim([1 100])
colormap parula
title('LFP 5 to 10 seconds')
ylabel('Frequency (Hz)')
xlabel('Peri-whisk time (sec)')
pause(1)

end