function [ComparisonData] = AnalyzeXCorr_Neuron2020(animalID,ComparisonData)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%_________________________________________________________________________________________________________________________
%
%   Purpose: Analyzes the cross correlation between various behavioral states and the vessel diameter.
%________________________________________________________________________________________________________________________

cd(animalID);     % Change to the subfolder for the current animal
dpFs = 5;         % Lowest two-photon sampling rate
wFs = 150;        % Whisker camera sampling rate
anFs = 20000;     % Analog (force sensor) sampling rate after initial processing

% Load necessary data structures and filenames from current directory
mergedDirectory = dir('*_MergedData.mat');
mergedDataFiles = {mergedDirectory.name}';
mergedDataFiles = char(mergedDataFiles);

% Load Resting baseline data structure
RestingBaselinesFile = dir('*_RestingBaselines.mat');
load(RestingBaselinesFile.name);

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

%% Analyze the cross-correlation with +/- 25 seconds of lag time
lagTime = 25;
frequency = dpFs;
maxLag = lagTime*frequency;
whiskerAngleXC_Means = cell(length(uniqueVesselIDs),1);    % PreAlloc
whiskerVelocityXC_Means = cell(length(uniqueVesselIDs),1); % PreAlloc
whiskerAccelXC_Means = cell(length(uniqueVesselIDs),1);    % PreAlloc
movementXC_Means = cell(length(uniqueVesselIDs),1);        % PreAlloc
for x = 1:length(uniqueVesselIDs)
    whiskerAngleXC_Vals = zeros(size(vesselData{x,1},2),maxLag*2 + 1);    % PreAlloc
    whiskerVelocityXC_Vals = zeros(size(vesselData{x,1},2),maxLag*2 + 1); % PreAlloc
    whiskerAccelXC_Vals = zeros(size(vesselData{x,1},2),maxLag*2 + 1);    % PreAlloc
    movementXC_Vals = zeros(size(vesselData{x,1},2),maxLag*2 + 1);        % PreAlloc
    for y = 1:size(vesselData{x,1},2)
        % Establish individual arrays for cross-correlation
        vesselArray = vesselData{x,1}(:,y);
        whiskerAngleArray = whiskerAngleData{x,1}(:,y);
        whiskerVelocityArray = whiskerVelocityData{x,1}(:,y);
        whiskerAccelArray = whiskerAccelData{x,1}(:,y);
        movementArray = movementData{x,1}(:,y);
        % Run cross-correlation between vessel diameter and each parameter
        [whiskerAngleXC_Vals(y,:),lags] = xcorr(vesselArray,whiskerAngleArray,maxLag,'coeff');
        [whiskerVelocityXC_Vals(y,:),~] = xcorr(vesselArray,whiskerVelocityArray,maxLag,'coeff');
        [whiskerAccelXC_Vals(y,:),~] = xcorr(vesselArray,whiskerAccelArray,maxLag,'coeff');
        [movementXC_Vals(y,:),~] = xcorr(vesselArray,movementArray,maxLag,'coeff');
    end
    % Take the mean across each vessel's individual events
    whiskerAngleXC_Means{x,1} = mean(whiskerAngleXC_Vals,1);
    whiskerVelocityXC_Means{x,1} = mean(whiskerVelocityXC_Vals,1);
    whiskerAccelXC_Means{x,1} = mean(whiskerAccelXC_Vals,1);
    movementXC_Means{x,1} = mean(movementXC_Vals,1);
end
lags = lags/frequency;

%% Determine how long each vessel was imaged on this particular day, as well as its resting baseline diameter
% Identify trial duration based on animal name
if strcmp(animalID,'T72') || strcmp(animalID,'T73') || strcmp(animalID,'T74') || strcmp(animalID,'T75') || strcmp(animalID,'T76')
    trialDuration = 280;   % seconds
else
    trialDuration = 900;
end
% Go through each file and determine vessel information
for a = 1:length(uniqueVesselIDs)
    uvID = uniqueVesselIDs{a,1};
    t = 1;
    for b = 1:size(mergedDataFiles,1)
        [~,~,~,vID,~] = GetFileInfo2_Neuron2020(mergedDataFiles(b,:));
        if strcmp(uvID, vID)
            timePerVessel{a,1} = t*trialDuration; %#ok<*AGROW>
            t = t + 1;
        end
    end
    vesselBaselines = [];
    timePerVessel{a,1} = timePerVessel{a,1}/60;
    fieldnames = fields(RestingBaselines.(uvID));
    for c = 1:length(fieldnames)
        fieldname = fieldnames{c,1};
        if ~isnan(RestingBaselines.(uvID).(fieldname).vesselDiameter.baseLine)
            vesselBaselines = [vesselBaselines RestingBaselines.(uvID).(fieldname).vesselDiameter.baseLine];
        end
    end
    vBaselines{a,1} = round(mean(vesselBaselines),1);
end
tblVals.vesselIDs = uniqueVesselIDs;
tblVals.timePerVessel = timePerVessel;
tblVals.baselines = vBaselines;

%% Save the results
ComparisonData.(animalID).XCorr.angle = whiskerAngleXC_Means;
ComparisonData.(animalID).XCorr.velocity = whiskerVelocityXC_Means;
ComparisonData.(animalID).XCorr.accel = whiskerAccelXC_Means;
ComparisonData.(animalID).XCorr.movement = movementXC_Means;
ComparisonData.(animalID).XCorr.lags = lags;
ComparisonData.(animalID).XCorr.vesselIDs = uniqueVesselIDs;
ComparisonData.(animalID).tblVals = tblVals;
cd ..

end
