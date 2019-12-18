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

cd(animalID);  % Change to the subfolder for the current animal
pFs = 20;      % T72,T73,T74,T75,T76,T80,T81 sampling rate 
dpFs = 5;      % T82,T83 sampling rate
wFs = 150;     % Whisker camera sampling rate
dsFs = 30;     % Analog (force sensor) sampling rate after initial processing

% Load necessary data structures and filenames from current directory
mergedDirectory = dir('*_MergedData.mat');
mergedDataFiles = {mergedDirectory.name}';
mergedDataFiles = char(mergedDataFiles);

%% Loop through all MergedData files in the directory and extract/process the vessel/whisker/movement data.
vesselIDs = cell(size(mergedDataFiles,1),1);
for a = 1:size(mergedDataFiles,1)
    mergedDataFile = mergedDataFiles(a,:);
    [~,~,~,vID,~] = GetFileInfo2_SlowOscReview2019(mergedDataFile);
    vesselIDs{a,1} = vID;
end

uniqueVesselIDs = unique(vesselIDs);
% Whisker angle/velocity/acceleration is processed first with 20 Hz lowpass ZPK
% Movement data is already processed with these identical parameters in StageTwoProcessing
filtThreshold = 20;
filtOrder = 2;
[z,p,k] = butter(filtOrder,filtThreshold/(wFs/2),'low');
[sos,g] = zp2sos(z,p,k);
% All data is low pass filtered 2 Hz as last processing step
[B,A] = butter(3,2/(dpFs/2),'low');
vesselData = cell(length(uniqueVesselIDs),1);          % PreAlloc
whiskerAngleData = cell(length(uniqueVesselIDs),1);    % PreAlloc
whiskerVelocityData = cell(length(uniqueVesselIDs),1); % PreAlloc
whiskerAccelData = cell(length(uniqueVesselIDs),1);    % PreAlloc
movementData = cell(length(uniqueVesselIDs),1);        % PreAlloc
for b = 1:length(uniqueVesselIDs)
    uniqueVesselID = string(uniqueVesselIDs{b,1});
    d = 1;
    for c = 1:size(mergedDataFiles, 1)
        mergedDataFile = mergedDataFiles(c,:);
        [~,~,~,mdID,~] = GetFileInfo2_SlowOscReview2019(mergedDataFile);
        if strcmp(uniqueVesselID,mdID) == true
            load(mergedDataFile);
            % Process the vesesl diameter. Resample if the original sampling rate is higher than 5 Hz
            if strcmp(animalID,'T82') || strcmp(animalID,'T83')
                vesselData{b,1}(:,d) = detrend(filtfilt(B,A,(MergedData.data.vesselDiameter - MergedData.data.vesselDiameter(1))),'constant');
            else
                vesselData{b,1}(:,d) = detrend(filtfilt(B,A,resample((MergedData.data.vesselDiameter - MergedData.data.vesselDiameter(1)),dpFs,pFs)),'constant');
            end
            % Process the whisker angle/velocity/acceleration data. Resample to match vessel data.
            whiskerAngleData{b,1}(:,d) = detrend(filtfilt(B,A,resample(filtfilt(sos,g,-MergedData.data.rawWhiskerAngle),dpFs,wFs)),'constant');
            whiskerVelocityData{b,1}(:,d) = detrend(filtfilt(B,A,resample(filtfilt(sos,g,(abs(diff(MergedData.data.rawWhiskerAngle,1)))),dpFs,wFs)),'constant');
            whiskerAccelData{b,1}(:,d) = detrend(filtfilt(B,A,resample(filtfilt(sos,g,(abs(diff(MergedData.data.rawWhiskerAngle,2)))),dpFs,wFs)),'constant');
            % Process the movement data. Resample to match vessel data.
            movementData{b,1}(:,d) = detrend(filtfilt(B,A,resample(abs(MergedData.data.forceSensorM),dpFs,dsFs)),'constant');
            d = d + 1;
        end
    end
end

%% Analyze the spectral coherence 
% Chronux coherence parameters
params.tapers = [10,19];
params.pad = 1;
params.Fs = dpFs; 
params.fpass = [0.05,0.5]; 
params.trialave = 1;
params.err = [2,0.05];
allWhiskerAngle_C = cell(length(vesselData),1);    % PreAlloc
allWhiskerVelocity_C = cell(length(vesselData),1); % PreAlloc
allWhiskerAccel_C = cell(length(vesselData),1);    % PreAlloc
allMovement_C = cell(length(vesselData),1);        % PreAlloc
all_f = cell(length(vesselData),1);                % PreAlloc
all_confC = cell(length(vesselData),1);            % PreAlloc
% Run coherence analysis between vessel diameter and each parameter
for e = 1:length(vesselData)
    % Whisker angle vs. Vessel Diameter
    [whiskerAngle_C,~,~,~,~,f,confC,~,~] = coherencyc_SlowOscReview2019(vesselData{e,1},whiskerAngleData{e,1},params);
    allWhiskerAngle_C{e,1} = whiskerAngle_C;
    all_f{e,1} = f;
    all_confC{e,1} = confC;
    % Whisker Velocity vs. Vessel Diameter
    [whiskerVelocity_C,~,~,~,~,~,~,~,~] = coherencyc_SlowOscReview2019(vesselData{e,1},whiskerVelocityData{e,1},params);
    allWhiskerVelocity_C{e,1} = whiskerVelocity_C;
    % Whisker Acceleration vs. Vessel Diameter
    [whiskerAccel_C,~,~,~,~,~,~,~,~] = coherencyc_SlowOscReview2019(vesselData{e,1},whiskerAccelData{e,1},params);
    allWhiskerAccel_C{e,1} = whiskerAccel_C;
    % Movement vs. Vessel Diameter
    [movement_C,~,~,~,~,~,~,~,~] = coherencyc_SlowOscReview2019(vesselData{e,1},movementData{e,1},params);
    allMovement_C{e,1} = movement_C;
end

%% Save the results
ComparisonData.(animalID).Coherence.angleC = allWhiskerAngle_C;
ComparisonData.(animalID).Coherence.velocityC = allWhiskerVelocity_C;
ComparisonData.(animalID).Coherence.accelC = allWhiskerAccel_C;
ComparisonData.(animalID).Coherence.movementC = allMovement_C;
ComparisonData.(animalID).Coherence.f = all_f;
ComparisonData.(animalID).Coherence.confC = all_confC;
ComparisonData.(animalID).Coherence.vesselIDs = uniqueVesselIDs;
cd ..

end
