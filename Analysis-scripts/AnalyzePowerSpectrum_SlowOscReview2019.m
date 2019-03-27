function [ComparisonData] = AnalyzePowerSpectrum_SlowOscReview2019(animalID, ComparisonData)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%_________________________________________________________________________________________________________________________
%
%   Purpose: Analyzes the spectral power of the abs(whiskerAccel) and vessel diameter.
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
    [~,~,~, vID] = GetFileInfo2_SlowOscReview2019(mergedDataFile);
    vesselIDs{a,1} = vID;
end

% For each vessel, pull the diameter and whisker angle
uniqueVesselIDs = unique(vesselIDs);
[B, A] = butter(4, 2/(p2Fs/2), 'low');   % 2 Hz low pass filter for vessels
t = 1;
for b = 1:length(uniqueVesselIDs)
    uniqueVesselID = string(uniqueVesselIDs{b,1});
    d = 1;
    for c = 1:size(mergedDataFiles, 1)
        mergedDataFile = mergedDataFiles(c,:);
        [~,~,~, mdID, ~] = GetFileInfo2_SlowOscReview2019(mergedDataFile);
        if strcmp(uniqueVesselID, mdID) == true
            load(mergedDataFile);
            % Detrend the filtered vessel diameter
            uniqueVesselData{b,1}(:,d) = detrend(filtfilt(B, A, MergedData.data.vesselDiameter), 'constant');
            % Detrend the absolute value of the whisker acceleration that was resampled down to 20 Hz (Fs of vessels)
            whiskerData(:,t) = detrend(filtfilt(B, A, abs(diff(resample(MergedData.data.whiskerAngle, p2Fs, dsFs), 2))), 'constant');
            d = d + 1;
            t = t + 1;
        end
    end
end

%% Chronux power spectrum parameters
params.tapers = [3 5];
params.pad = 1;
params.Fs = p2Fs;
params.fpass = [0.004 0.5]; 
params.trialave = 1;
params.err = [2 0.05];

% Lop through the data and find the power spectrum for each vessel/whisker acceleration
for e = 1:length(uniqueVesselData)
    [S, f, ~] = mtspectrumc_SlowOscReview2019(uniqueVesselData{e,1}, params);
    allS{e,1} = S;
    allf{e,1} = f;
end
[wS, wf, ~] = mtspectrumc_SlowOscReview2019(whiskerData, params);

%% Save the results.
ComparisonData.(animalID).Vessel_PowerSpec.S = allS;
ComparisonData.(animalID).Vessel_PowerSpec.f = allf;
ComparisonData.(animalID).Vessel_PowerSpec.vesselIDs = uniqueVesselIDs;
ComparisonData.(animalID).Whisk_PowerSpec.S = wS;
ComparisonData.(animalID).Whisk_PowerSpec.f = wf;
cd ..

end