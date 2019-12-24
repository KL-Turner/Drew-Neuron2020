function [] = DetermineVesselStatistics_Neuron2020(ComparisonData)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Use the results structure to display how many minutes of time were used in the previous analysis for
%            each unique vessel.
%________________________________________________________________________________________________________________________

animalIDs = fields(ComparisonData);
x = 1;
% Loop through each animal and pull the results that were calculated in AnalyzeEvokedResponses
for a = 1:length(animalIDs)
    animalID = animalIDs{a};  
    for b = 1:length(ComparisonData.(animalID).tblVals.vesselIDs)
        animal{x,1} = animalID;
        vesselID{x,1} = ComparisonData.(animalID).tblVals.vesselIDs{b,1};
        baselineDiam{x,1} = ComparisonData.(animalID).tblVals.baselines{b,1};
        minutesPerVessel{x,1} = ComparisonData.(animalID).tblVals.timePerVessel{b,1};
        x = x + 1;
    end
end

% Table
T = table(animal,vesselID,baselineDiam,minutesPerVessel,'VariableNames',{'Animal_ID','Vessel_ID','Baseline_diameter_um','Total_minutes_per_Vessel'});
figure('Name', 'Individual vessel imaging information', 'NumberTitle', 'off')
u = uitable('Data',T{:,:},'ColumnName',T.Properties.VariableNames,'RowName',T.Properties.RowNames,'Units','Normalized','Position',[0,0,1,1]);
set(u,'ColumnWidth',{125})
pause(1)

end
