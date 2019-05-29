function FigFour_SlowOscReview2019(ComparisonData)
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
x = 1;
y = 1;
c = 1;
d = 1;
for a = 1:length(animalIDs)
    animalID = animalIDs{a,1};
    for b = 1:length(ComparisonData.(animalID).Vessel_PowerSpec.S)
        try
            powerspecVesselData1(x,:) = ComparisonData.(animalID).Vessel_PowerSpec.S{b,1};
            vID = join([string(animalID) string(ComparisonData.(animalID).Vessel_PowerSpec.vesselIDs{b,1})]);
            vIDs1{x,1} = strrep(vID, ' ', '');
            x = x + 1;
        catch
            powerspecVesselData2(y,:) = ComparisonData.(animalID).Vessel_PowerSpec.S{b,1};
            vID = join([string(animalID) string(ComparisonData.(animalID).Vessel_PowerSpec.vesselIDs{b,1})]);
            vIDs2{y,1} = strrep(vID, ' ', '');
            y = y + 1;
        end
    end
    try
        powerspecWhiskData1(c,:) = ComparisonData.(animalID).Whisk_PowerSpec.S;
        vf1 = ComparisonData.(animalID).Vessel_PowerSpec.f{1,1};
        wf1 = ComparisonData.(animalID).Whisk_PowerSpec.f;
        c = c + 1;
    catch
        powerspecWhiskData2(d,:) = ComparisonData.(animalID).Whisk_PowerSpec.S;
        vf2 = ComparisonData.(animalID).Vessel_PowerSpec.f{1,1};
        wf2 = ComparisonData.(animalID).Whisk_PowerSpec.f;
        d = d + 1;
    end
end

%% Adjust for differences in trial duration
f1_f2_logical = ismember(vf2, vf1);
for e = 1:size(powerspecVesselData2, 1)
    vesselData = powerspecVesselData2(e,:);
    logicalVesselData = vesselData(f1_f2_logical);
    powerspecVesselData1(x,:) = logicalVesselData;
    vIDs1{x,1} = vIDs2{e,1};
    x = x + 1;
end

f3_f4_logical = ismember(wf2, wf1);
for f = 1:size(powerspecWhiskData2, 1)
    whiskData = powerspecWhiskData2(f,:);
    logicalWhiskData = whiskData(f3_f4_logical);
    powerspecWhiskData1(c,:) = logicalWhiskData;
    c = c + 1;
end

%% Averages
powerspecVesselMean = mean(powerspecVesselData1,1);
powerspecVesselSTD = std(powerspecVesselData1,1,1);
powerspecWhiskMean = mean(powerspecWhiskData1,1);
powerspecWhiskSTD = std(powerspecWhiskData1,1,1);

%%
figure;
ax1 = subplot(1,2,1);
loglog(vf1, powerspecVesselMean, 'k', 'LineWidth', 2)
hold on
loglog(vf1, powerspecVesselMean + powerspecVesselSTD, 'Color', colors_SlowOscReview2019('ash grey'))
loglog(vf1, powerspecVesselMean - powerspecVesselSTD, 'Color', colors_SlowOscReview2019('ash grey'))
title('Mean power spec vessel diameter')
xlabel('Frequency (Hz)')
ylabel('Power')
xlim([0.05 0.5])

ax2 = subplot(1,2,2);
loglog(wf1, powerspecWhiskMean, 'k', 'LineWidth', 2)
hold on
loglog(wf1, powerspecWhiskMean + powerspecWhiskSTD, 'Color', colors_SlowOscReview2019('ash grey'))
loglog(wf1, powerspecWhiskMean - powerspecWhiskSTD, 'Color', colors_SlowOscReview2019('ash grey'))
title('Mean power spec abs(whiskerAccel)')
xlabel('Frequency (Hz)')
ylabel('Power')
xlim([0.05 0.5])
linkaxes([ax1 ax2], 'xy')
pause(1)

end