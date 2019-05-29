function [ComparisonData] = AnalyzeCoherence_SlowOscReview2019(animalID, ComparisonData)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%_________________________________________________________________________________________________________________________
%
%   Purpose: Analyzes the coherence between abs(whiskerAccel) and vessel diameter.
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
if strcmp(animalID, 'T72') || strcmp(animalID, 'T73') || strcmp(animalID, 'T74') || strcmp(animalID, 'T75') || strcmp(animalID, 'T76') 
    p2Fs = 20;   % Two-photon Fs is 20 Hz
elseif strcmp(animalID, 'T80') || strcmp(animalID, 'T81')
    p2Fs = 20;
elseif strcmp(animalID, 'T82') || strcmp(animalID, 'T83')
    p2Fs = 5;
end
dsFs = 150;   % Down-sampled Fs is 30 Hz

% Load necessary data structures and filenames from current directory
mergedDirectory = dir('*_MergedData.mat');
mergedDataFiles = {mergedDirectory.name}';
mergedDataFiles = char(mergedDataFiles);

%% Loop through all MergedData files in the directory and extract the unique vessel data/whisker data.
vesselIDs = {};
for a = 1:size(mergedDataFiles, 1)
    mergedDataFile = mergedDataFiles(a,:);
    [~,~,~, vID, ~] = GetFileInfo2_SlowOscReview2019(mergedDataFile);
    vesselIDs{a,1} = vID;
end

filtThreshold = 20;
filtOrder = 2;
[z, p, k] = butter(filtOrder, filtThreshold/(150/2), 'low');
[sos, g] = zp2sos(z, p, k);

% For each vessel, pull the diameter and whisker angle
uniqueVesselIDs = unique(vesselIDs);
for b = 1:length(uniqueVesselIDs)
    uniqueVesselID = string(uniqueVesselIDs{b,1});
    d = 1;
    for c = 1:size(mergedDataFiles, 1)
        mergedDataFile = mergedDataFiles(c,:);
        [~, ~, ~, mdID, ~] = GetFileInfo2_SlowOscReview2019(mergedDataFile);
        if strcmp(uniqueVesselID, mdID) == true
            load(mergedDataFile);
            % Detrend the filtered vessel diameter
            uniqueVesselData{b,1}(:,d) = detrend(MergedData.data.vesselDiameter, 'constant');
            % Detrend the filtered absolute value of the whisker acceleration that was resampled down to 20 Hz (Fs of vessels)
            uniqueWhiskerData{b,1}(:,d) = resample(filtfilt(sos, g, (abs(diff(MergedData.data.rawWhiskerAngle, 2)))), p2Fs, dsFs);
            d = d + 1;
        end
    end
end

%% Chronux coherence parameters
params.tapers = [10 19];
params.pad = 1;
params.Fs = p2Fs; 
params.fpass = [0.05 0.5]; 
params.trialave = 1;
params.err = [2 0.05];

% Lop through the data and find the coherence for each vessel/corresponding whisker acceleration
for e = 1:length(uniqueVesselData)
    [C, ~, ~, ~, ~, f, confC, ~, cErr] = coherencyc_SlowOscReview2019(uniqueVesselData{e,1}, uniqueWhiskerData{e,1}, params);
    allC{e,1} = C;
    allf{e,1} = f;
    allconfC{e,1} = confC;
    allcErr{e,1} = cErr; 
end

%% Shuffle and calculate coherence 1000 times
% for f = 1:length(uniqueVesselData)
%     vesselData = uniqueVesselData{f,1};
%     whiskData = uniqueWhiskerData{f,1};
%     for g = 1:1000
%         shuffledWhiskData = whiskData(:, randperm(size(whiskData, 2)));
%         [C, ~, ~, ~, ~, ~, ~, ~, ~] = coherencyc_SlowOscReview2019(vesselData, shuffledWhiskData, params);
%         shuffledC(:,g) = C;
%     end
%     shuffledC_means{f,1} = mean(shuffledC, 2);
% end

%% Save the results.
ComparisonData.(animalID).WhiskVessel_Coherence.C = allC;
% ComparisonData.(animalID).WhiskVessel_Coherence.shuffC = shuffledC_means;
ComparisonData.(animalID).WhiskVessel_Coherence.confC = allconfC;
ComparisonData.(animalID).WhiskVessel_Coherence.f = allf;
ComparisonData.(animalID).WhiskVessel_Coherence.vesselIDs = uniqueVesselIDs;
cd ..

end
