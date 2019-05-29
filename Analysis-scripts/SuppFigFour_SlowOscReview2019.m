function SuppFigFour_SlowOscReview2019(ComparisonData)
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



%%
figure;
ax1 = subplot(1,2,1);
for c = 1:size(powerspecVesselData1, 1)
    vID = char(vIDs1{c,1});
    animalName = vID(1:3);
    switch animalName
        case 'T72'
            animalColor = colors_SlowOscReview2019('candy apple red');
        case 'T73'
            animalColor = colors_SlowOscReview2019('deep carrot orange');
        case 'T74'
            animalColor = colors_SlowOscReview2019('vegas gold');
        case 'T75'
            animalColor = colors_SlowOscReview2019('jungle green');
        case 'T76'
            animalColor = colors_SlowOscReview2019('sapphire');
        case 'T80'
            animalColor = colors_SlowOscReview2019('otter brown');
        case 'T81'
            animalColor = colors_SlowOscReview2019('royal purple');
        case 'T82'
            animalColor = colors_SlowOscReview2019('flamingo pink');
        case 'T83'
            animalColor = colors_SlowOscReview2019('smoky black');
    end
    loglog(vf1, powerspecVesselData1(c,:), 'LineWidth', 1.5, 'Color', animalColor);
    hold on
end
title('Ind power spec vessel diameter')
xlabel('Frequency (Hz)')
ylabel('Power')
legend(vIDs1)
xlim([0.05 0.5])

ax2 = subplot(1,2,2);
for d = 1:size(powerspecWhiskData1,1)
    animalName = animalIDs{d,1};
    switch animalName
        case 'T72'
            animalColor = colors_SlowOscReview2019('candy apple red');
        case 'T73'
            animalColor = colors_SlowOscReview2019('deep carrot orange');
        case 'T74'
            animalColor = colors_SlowOscReview2019('vegas gold');
        case 'T75'
            animalColor = colors_SlowOscReview2019('jungle green');
        case 'T76'
            animalColor = colors_SlowOscReview2019('sapphire');
        case 'T80'
            animalColor = colors_SlowOscReview2019('otter brown');
        case 'T81'
            animalColor = colors_SlowOscReview2019('royal purple');
        case 'T82'
            animalColor = colors_SlowOscReview2019('flamingo pink');
        case 'T83'
            animalColor = colors_SlowOscReview2019('smoky black');
    end
    loglog(wf1, powerspecWhiskData1(d,:), 'LineWidth', 1.5, 'Color', animalColor);
    hold on
end
title('Ind power spec abs(whiskerAccel)')
xlabel('Frequency (Hz)')
ylabel('Power')
legend(animalIDs)
xlim([0.05 0.5])
linkaxes([ax1 ax2], 'xy')
pause(1)

end