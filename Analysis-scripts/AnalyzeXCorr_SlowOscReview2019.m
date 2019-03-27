function [ComparisonData] = AnalyzeXCorr_SlowOscReview2019(animalID, ComparisonData)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%_________________________________________________________________________________________________________________________
%
%   Purpose: Analyzes the cross correlation between abs(whiskerAccel) and vessel diameter.
%________________________________________________________________________________________________________________________
%
%   Inputs: animal ID ('T##') [string]
%           ComparisonData.mat structure to save the results under than animal's ID
%
%   Outputs: Updated ComparisonData.mat structure
%
%   Last Revised: March 24th, 2019
%________________________________________________________________________________________________________________________

cd(animalID);   % Change to the subfolder for the current animal
p2Fs = 20;   % Two-photon Fs is 20 Hz
dsFs = 30;   % Down-sampled Fs is 30 Hz

% Load necessary data structures and filenames from current directory
mergedDirectory = dir('*_MergedData.mat');
mergedDataFiles = {mergedDirectory.name}';
mergedDataFiles = char(mergedDataFiles);

%% Loop through all MergedData files in the directory and extract the unique vessel data/whisker data.
vesselIDs = {};
for a = 1:size(mergedDataFiles, 1)
    mergedDataFile = mergedDataFiles(a,:);
    [~,~,~, vID,~] = GetFileInfo2_SlowOscReview2019(mergedDataFile);
    vesselIDs{a,1} = vID;
end

% For each vessel, pull the diameter and whisker angle
uniqueVesselIDs = unique(vesselIDs);
[B, A] = butter(4, 2/(p2Fs/2), 'low');   % 2 Hz low pass filter for vessels
for b = 1:length(uniqueVesselIDs)
    uniqueVesselID = string(uniqueVesselIDs{b,1});
    d = 1;
    for c = 1:size(mergedDataFiles, 1)
        mergedDataFile = mergedDataFiles(c,:);
        [~,~,~, mdID,~] = GetFileInfo2_SlowOscReview2019(mergedDataFile);
        if strcmp(uniqueVesselID, mdID) == true
            load(mergedDataFile);
            % Detrend the filtered vessel diameter
            uniqueVesselData{b,1}(:,d) = detrend(filtfilt(B, A, MergedData.data.vesselDiameter(2:end - 1)), 'constant');
            % Detrend the filtered absolute value of the whisker acceleration that was resampled down to 20 Hz (Fs of vessels)
            uniqueWhiskerData{b,1}(:,d) = detrend(filtfilt(B, A, abs(diff(resample(MergedData.data.whiskerAngle, p2Fs, dsFs), 2))), 'constant');
            d = d + 1;
        end
    end
end

%% Analyze the cross-correlation with +/- 25 seconds of lags.
lagTime = 25;
frequency = 20;
maxLag = lagTime*frequency;
for x = 1:length(uniqueVesselIDs)
    for y = 1:size(uniqueVesselData{x, 1}, 2)
        vesselArray = uniqueVesselData{x,1}(:,y);
        whiskArray = uniqueWhiskerData{x,1}(:,y);
        [XC_Vals(y, :), lags] = xcorr(vesselArray, whiskArray, maxLag, 'coeff');
    end
    XC_means{x,1} = mean(XC_Vals, 1);
end
lags = lags/frequency;

%% Save the results.
ComparisonData.(animalID).WhiskVessel_XCorr.XC_means = XC_means;
ComparisonData.(animalID).WhiskVessel_XCorr.lags = lags;
ComparisonData.(animalID).WhiskVessel_XCorr.vesselIDs = uniqueVesselIDs;
cd ..

end
