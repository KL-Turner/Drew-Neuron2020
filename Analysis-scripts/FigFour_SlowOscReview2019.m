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
for a = 1:length(animalIDs)
    animalID = animalIDs{a,1};
    for b = 1:length(ComparisonData.(animalID).Vessel_PowerSpec.S)
        powerspecVesselData(x,:) = ComparisonData.(animalID).Vessel_PowerSpec.S{b,1};
        x = x + 1;
    end 
    powerspecWhiskData(a,:) = ComparisonData.(animalID).Whisk_PowerSpec.S;
end
vf = ComparisonData.(animalID).Vessel_PowerSpec.f{1,1};
powerspecVesselMean = mean(powerspecVesselData,1);
powerspecVesselSTD = std(powerspecVesselData,1,1);
wf = ComparisonData.(animalID).Whisk_PowerSpec.f;
powerspecWhiskMean = mean(powerspecWhiskData,1);
powerspecWhiskSTD = std(powerspecWhiskData,1,1);

%%
figure;
ax1 = subplot(1,2,1);
loglog(vf, powerspecVesselMean, 'k')
hold on
loglog(vf, powerspecVesselMean + powerspecVesselSTD)
loglog(vf, powerspecVesselMean - powerspecVesselSTD)
title('Mean power spec vessel diameter')
xlabel('Frequency (Hz)')
ylabel('Power')
xlim([0 0.5])

ax2 = subplot(1,2,2);
loglog(wf, powerspecWhiskMean, 'k')
hold on
loglog(wf, powerspecWhiskMean + powerspecWhiskSTD)
loglog(wf, powerspecWhiskMean - powerspecWhiskSTD)
title('Mean power spec abs(whiskerAccel)')
xlabel('Frequency (Hz)')
ylabel('Power')
xlim([0 0.5])
linkaxes([ax1 ax2], 'xy')
pause(1)

end