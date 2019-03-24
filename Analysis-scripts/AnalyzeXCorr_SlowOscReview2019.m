function [ComparisonData] = AnalyzeXCorr_SlowOscReview2019(animalID, ComparisonData)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% Ph.D. Candidate, Department of Bioengineering
% The Pennsylvania State University
%________________________________________________________________________________________________________________________
%
%   Purpose: //
%________________________________________________________________________________________________________________________
%
%   Inputs: //
%
%   Outputs: //
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
for b = 1:length(uniqueVesselIDs)
    uniqueVesselID = string(uniqueVesselIDs{b,1});
    d = 1;
    for c = 1:size(mergedDataFiles, 1)
        mergedDataFile = mergedDataFiles(c,:);
        [~,~,~, mdID,~] = GetFileInfo_SlowOscReview2019P(mergedDataFile);
        if strcmp(uniqueVesselID, mdID) == true
            load(mergedDataFile);
            uniqueVesselData{b,1}(:,d) = detrend(filtfilt(B, A, MergedData.data.vesselDiameter(2:end - 1)), 'constant');
            uniqueWhiskerData{b,1}(:,d) = detrend(abs(diff(resample(MergedData.data.whiskerAngle, p2Fs, dsFs), 2)), 'constant');
            d = d + 1;
        end
    end
end

%%
z_hold = [];
lagTime = 25;       % Seconds
frequency = 20;     % Hz
maxLag = lagTime*frequency;    % Number of points
for x = 1:length(uniqueVesselIDs)
    z_hold = [];
    for y = 1:size(uniqueVesselData{x, 1}, 2)
        vesselArray = uniqueVesselData{x,1}(:,y);
        whiskArray = uniqueWhiskerData{x,1}(:,y);
        [XC_Vals(y, :), lags] = xcorr(vesselArray, whiskArray, maxLag, 'coeff');
    end
    XC_means{x,1} = mean(XC_Vals, 1);
end
lags = lags/frequency;

%%
ComparisonData.(animalID).WhiskVessel_XCorr.XC_means = XC_means;
ComparisonData.(animalID).WhiskVessel_XCorr.lags = lags;
ComparisonData.(animalID).WhiskVessel_XCorr.vesselIDs = uniqueVesselIDs;
cd ..

end