function [ComparisonData] = AnalyzeCoherence_Neuron2020(animalID, ComparisonData)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%_________________________________________________________________________________________________________________________
%
%   Purpose: Analyzes the coherence between abs(whiskerAccel) and vessel diameter.
%________________________________________________________________________________________________________________________

cd(animalID);     % Change to the subfolder for the current animal
dpFs = 5;         % Lowest two-photon sampling rate
wFs = 150;        % Whisker camera sampling rate
anFs = 20000;     % Analog (force sensor) sampling rate after initial processing

% Load necessary data structures and filenames from current directory
mergedDirectory = dir('*_MergedData.mat');
mergedDataFiles = {mergedDirectory.name}';
mergedDataFiles = char(mergedDataFiles);

%% Loop through all MergedData files in the directory and extract/process the vessel/whisker/movement data.
vesselIDs = cell(size(mergedDataFiles,1),1);
for a = 1:size(mergedDataFiles,1)
    mergedDataFile = mergedDataFiles(a,:);
    [~,~,~,vID,~] = GetFileInfo2_Neuron2020(mergedDataFile);
    vesselIDs{a,1} = vID;
end

uniqueVesselIDs = unique(vesselIDs);
% Whisker angle/velocity/acceleration is processed first with 20 Hz lowpass ZPK
% Movement data is already processed with these identical parameters in StageTwoProcessing
[z1,p1,k1] = butter(2,20/(wFs/2),'low');
[sos1,g1] = zp2sos(z1,p1,k1);
[z2,p2,k2] = butter(2,20/(anFs/2),'low');
[sos2,g2] = zp2sos(z2,p2,k2);
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
        [~,~,~,mdID,~] = GetFileInfo2_Neuron2020(mergedDataFile);
        if strcmp(uniqueVesselID,mdID) == true
            load(mergedDataFile);
            % Process the vesesl diameter. Resample if the original sampling rate is higher than 5 Hz
            vesselData{b,1}(:,d) = detrend(filtfilt(B,A,(MergedData.data.vesselDiameter - MergedData.data.vesselDiameter(1))),'constant');
            % Process the whisker angle/velocity/acceleration data. Resample to match vessel data.
            whiskerAngleData{b,1}(:,d) = detrend(filtfilt(B,A,resample(filtfilt(sos1,g1,abs(MergedData.data.rawWhiskerAngle - 135)),dpFs,wFs)),'constant');
            whiskerVelocityData{b,1}(:,d) = detrend(filtfilt(B,A,resample(filtfilt(sos1,g1,(abs(diff(MergedData.data.rawWhiskerAngle,1)))),dpFs,wFs)),'constant');
            whiskerAccelData{b,1}(:,d) = detrend(filtfilt(B,A,resample(filtfilt(sos1,g1,(abs(diff(MergedData.data.rawWhiskerAngle,2)))),dpFs,wFs)),'constant');
            % Process the movement data. Resample to match vessel data.
            movementData{b,1}(:,d) = detrend(filtfilt(B,A,resample(filtfilt(sos2,g2,abs(MergedData.data.rawForceSensorM)),dpFs,anFs)),'constant');
            d = d + 1;
        end
    end
end

%% Analyze the spectral coherence 
% Chronux coherence parameters
params.tapers = [10,19];
params.pad = 1;
params.Fs = dpFs; 
params.fpass = [0,0.5]; 
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
    [whiskerAngle_C,~,~,~,~,f,confC,~,~] = coherencyc_Neuron2020(vesselData{e,1},whiskerAngleData{e,1},params);
    allWhiskerAngle_C{e,1} = whiskerAngle_C;
    all_f{e,1} = f;
    all_confC{e,1} = confC;
    % Whisker Velocity vs. Vessel Diameter
    [whiskerVelocity_C,~,~,~,~,~,~,~,~] = coherencyc_Neuron2020(vesselData{e,1},whiskerVelocityData{e,1},params);
    allWhiskerVelocity_C{e,1} = whiskerVelocity_C;
    % Whisker Acceleration vs. Vessel Diameter
    [whiskerAccel_C,~,~,~,~,~,~,~,~] = coherencyc_Neuron2020(vesselData{e,1},whiskerAccelData{e,1},params);
    allWhiskerAccel_C{e,1} = whiskerAccel_C;
    % Movement vs. Vessel Diameter
    [movement_C,~,~,~,~,~,~,~,~] = coherencyc_Neuron2020(vesselData{e,1},movementData{e,1},params);
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
