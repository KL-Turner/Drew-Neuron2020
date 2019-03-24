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
for a = 1:length(animalIDs)
    animalID = animalIDs{a,1};
    for b = 1:length(ComparisonData.(animalID).Vessel_PowerSpec.S)
        powerspecVesselData(x,:) = ComparisonData.(animalID).Vessel_PowerSpec.S{b,1};
        vID = join([string(animalID) string(ComparisonData.(animalID).Vessel_PowerSpec.vesselIDs{b,1})]);
        vIDs{x,1} = strrep(vID, ' ', '');
        x = x + 1;
    end 
    powerspecWhiskData(a,:) = ComparisonData.(animalID).Whisk_PowerSpec.S;
end

vf = ComparisonData.(animalID).Vessel_PowerSpec.f{1,1};
wf = ComparisonData.(animalID).Whisk_PowerSpec.f;

%%
figure;
ax1 = subplot(1,2,1);
for c = 1:size(powerspecVesselData, 1)
    loglog(vf, powerspecVesselData(c,:));
    hold on
end
title('Ind power spec vessel diameter')
xlabel('Frequency (Hz)')
ylabel('Power')
legend(vIDs)
xlim([0 0.5])

ax2 = subplot(1,2,2);
for c = 1:size(powerspecWhiskData,1)
    loglog(wf, powerspecWhiskData(c,:));
    hold on
end
title('Ind power spec abs(whiskerAccel)')
xlabel('Frequency (Hz)')
ylabel('Power')
legend(animalIDs)
xlim([0 0.5])
linkaxes([ax1 ax2], 'xy')
pause(1)

end