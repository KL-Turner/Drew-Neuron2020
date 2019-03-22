function [ComparisonData] = AnalyzePowerSpectrum_SlowOscReview2019(animalID, ComparisonData)
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
%   Last Revised: March 18th, 2019
%________________________________________________________________________________________________________________________

cd(animalID);
p2Fs = 20;
dsFs = 30;

mergedDirectory = dir('*_MergedData.mat');
mergedDataFiles = {mergedDirectory.name}';
mergedDataFiles = char(mergedDataFiles);

%%
vesselIDs = {};
for a = 1:size(mergedDataFiles, 1)
    mergedDataFile = mergedDataFiles(a,:);
    [~,~,~, vID] = GetFileInfo2_SlowOscReview2019(mergedDataFile);
    vesselIDs{a,1} = vID;
end

uniqueVesselIDs = unique(vesselIDs);
[B, A] = butter(4, 2/(p2Fs/2), 'low');
t = 1;
for b = 1:length(uniqueVesselIDs)
    uniqueVesselID = string(uniqueVesselIDs{b,1});
    d = 1;
    for c = 1:size(mergedDataFiles, 1)
        mergedDataFile = mergedDataFiles(c,:);
        [~,~,~, mdID, ~] = GetFileInfo2_SlowOscReview2019(mergedDataFile);
        if strcmp(uniqueVesselID, mdID) == true
            load(mergedDataFile);
            uniqueVesselData{b,1}(:,d) = detrend(filtfilt(B, A, MergedData.data.vesselDiameter), 'constant');
            whiskerData(:,t) = detrend(abs(diff(resample(MergedData.data.whiskerAngle, p2Fs, dsFs), 2)), 'constant');
            d = d + 1;
            t = t + 1;
        end
    end
end

for k = 1:length(uniqueVesselIDs)
    uniqueVesselIDs{k,1} = [animalID uniqueVesselIDs{k,1}];
end

params.tapers = [3 5];
params.pad = 1;
params.Fs = p2Fs;
params.fpass = [0 0.5]; 
params.trialave = 1;
params.err = [2 0.05];

%%
for e = 1:length(uniqueVesselData)
    [S, f, sErr] = mtspectrumc_SlowOscReview2019(uniqueVesselData{e,1}, params);
    allS{e,1} = S;
    allf{e,1} = f;
    allsErr{e,1} = sErr;
end

[wS, wf, ~] = mtspectrumc_SlowOscReview2019(whiskerData, params);

%%
ComparisonData.(animalID).Vessel_PowerSpec.S = allS;
ComparisonData.(animalID).Vessel_PowerSpec.f = allf;
ComparisonData.(animalID).Vessel_PowerSpec.vesselIDs = uniqueVesselIDs;
ComparisonData.(animalID).Whisk_PowerSpec.S = wS;
ComparisonData.(animalID).Whisk_PowerSpec.f = wf;
cd ..

end