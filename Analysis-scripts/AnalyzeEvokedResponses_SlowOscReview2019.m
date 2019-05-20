function [ComparisonData] = AnalyzeEvokedResponses_SlowOscReview2019(animalID, ComparisonData)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%_________________________________________________________________________________________________________________________
%
%   Purpose: Analyzes the whisking-evoked changes in vessel diameter and LFP
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
    trialDuration = 280;   % 4 minutes, 40 seconds. ten seconds were previously removed from beginning/end
elseif strcmp(animalID, 'T80') || strcmp(animalID, 'T81') || strcmp(animalID, 'T82') || strcmp(animalID, 'T83')
    p2Fs = 20;
    trialDuration = 900;
elseif strcmp(animalID, 'T82b') || strcmp(animalID, 'T83b')
    p2Fs = 5;
    trialDuration = 900;
end

offset = 4;   % Look four seconds prior to the start of a whisking event
duration = 10;   % Look ten seconds after the start of a whisking event

% Load necessary data structures and filenames from current directory
EventDataFile = dir('*_EventData.mat');
load(EventDataFile.name);
RestingBaselinesFile = dir('*_RestingBaselines.mat');
load(RestingBaselinesFile.name);
specDirectory = dir('*_SpecData.mat');
specDataFiles = {specDirectory.name}';
specDataFiles = char(specDataFiles);

%% Extract the events that meet our desired criteria.
% Whisking events that last between 0.5 and 2 seconds long
whiskCriteria.Fieldname{1,1} = {'duration', 'duration', 'puffDistance'};
whiskCriteria.Comparison{1,1} = {'gt','lt','gt'};
whiskCriteria.Value{1,1} = {0.5, 2, 5};

% Whisking events that last between 2 and 5 seconds long
whiskCriteria.Fieldname{2,1} = {'duration', 'duration', 'puffDistance'};
whiskCriteria.Comparison{2,1} = {'gt','lt','gt'};
whiskCriteria.Value{2,1} = {2, 5, 5};

% Whisking events that last between 5 and 10 seconds long
whiskCriteria.Fieldname{3,1} = {'duration', 'duration', 'puffDistance'};
whiskCriteria.Comparison{3,1} = {'gt', 'lt', 'gt'};
whiskCriteria.Value{3,1} = {5, 10, 5};

whiskData = cell(length(whiskCriteria.Fieldname), 1);   % Pre-allocate
whiskVesselIDs = cell(length(whiskCriteria.Fieldname), 1);
whiskEventTimes = cell(length(whiskCriteria.Fieldname), 1);
whiskFileIDs = cell(length(whiskCriteria.Fieldname), 1);

% Extract events, IDs, and other file information for each criteria
for x = 1:length(whiskCriteria.Fieldname)
    criteria.Fieldname = whiskCriteria.Fieldname{x,1};
    criteria.Comparison = whiskCriteria.Comparison{x,1};
    criteria.Value = whiskCriteria.Value{x,1};
    whiskFilter = FilterEvents_SlowOscReview2019(EventData.vesselDiameter.whisk, criteria);
    [tempWhiskData] = EventData.vesselDiameter.whisk.data(whiskFilter, :);
    whiskData{x,1} = tempWhiskData;
    [tempWhiskVesselIDs] = EventData.vesselDiameter.whisk.vesselIDs(whiskFilter, :);
    whiskVesselIDs{x,1} = tempWhiskVesselIDs;
    [tempWhiskEventTimes] = EventData.vesselDiameter.whisk.eventTime(whiskFilter, :);
    whiskEventTimes{x,1} = tempWhiskEventTimes;
    [tempWhiskFileIDs] = EventData.vesselDiameter.whisk.fileIDs(whiskFilter, :);
    whiskFileIDs{x,1} = tempWhiskFileIDs;
end

%% Go through each unique vessel and separate all the data per vessel.
processedWhiskData.data = cell(length(whiskData), 1);
for x = 1:length(whiskData)
    uniqueVesselIDs = unique(whiskVesselIDs{x,1});
    for y = 1:length(uniqueVesselIDs)
        uniqueVesselID = uniqueVesselIDs{y,1};
        w = 1;
        for z = 1:length(whiskVesselIDs{x,1})
            vesselID = whiskVesselIDs{x,1}{z,1};
            if strcmp(uniqueVesselID, vesselID)
                fileID = whiskFileIDs{x,1}{z,1};
                strDay = ConvertDate_SlowOscReview2019(fileID(1:6));
                vesselDiam = whiskData{x,1}(z,:);
                % Normalize vessel diameter by resting baseline
                normVesselDiam = (vesselDiam - RestingBaselines.(uniqueVesselID).(strDay).vesselDiameter.baseLine)./(RestingBaselines.(vesselID).(strDay).vesselDiameter.baseLine);
                % Filter normalized diameter with a Savitzky-Golay filter
                filtVesselDiam = sgolayfilt(normVesselDiam, 3, 17)*100;
                % Mean-subtract the first four seconds prior to the whisking event starting
                processedWhiskData.data{x,1}{y,1}(w,:) = filtVesselDiam - mean(filtVesselDiam(1:offset*p2Fs));
                processedWhiskData.vesselIDs{x,1}{y,1}{w} = vesselID;
                w = w + 1;
            end
        end
    end
end

% Find the mean whisking-evoked vessel diameter change for each different whisking criteria 
whiskCritMeans.data = cell(length(processedWhiskData.data),1);
for x = 1:length(processedWhiskData.data)
    for y = 1:length(processedWhiskData.data{x,1})
        whiskCritMeans.data{x,1}{y,1} = mean(processedWhiskData.data{x,1}{y,1},1);
    end
end

%% Go through each unique day and extract the corresponding neural LFP during the corresponding whisking events.
for w = 1:length(whiskFileIDs)
    whiskZhold = [];
    sFiles = whiskFileIDs{w,1};
    sEventTimes = whiskEventTimes{w,1};
    for x = 1:length(sFiles)   % Loop through each non-unique file
        whiskFileID = sFiles{x, 1};
        % Load in Neural Data from rest period
        for s = 1:size(specDataFiles,1)
            [~, ~, specDataFileID, vesselID, imageID] = GetFileInfo2_SlowOscReview2019(specDataFiles(s,:));
            if strcmp(whiskFileID, specDataFileID)
                load([animalID '_' vesselID '_' specDataFileID '_' imageID '_SpecData.mat'], '-mat');
                whiskS_Data = SpecData.oneSec.normS;  % Normalized S data for this specific file
            end
        end
        whiskSLength = size(whiskS_Data, 2);
        whiskBinSize = ceil(whiskSLength/trialDuration);
        whiskSamplingDiff = p2Fs/whiskBinSize;
        
        % Find the start time and duration
        startTime = floor(floor(sEventTimes(x,1)*p2Fs)/whiskSamplingDiff);
        if startTime == 0
            startTime = 1;
        end
        
        % Take the S_data from the start time throughout the duration
        try
            whiskS_Vals = whiskS_Data(:, (startTime - (offset*whiskBinSize)):(startTime + ((duration)*whiskBinSize)));
        catch
            whiskS_Vals = whiskS_Data(:, end - ((duration+offset)*whiskBinSize):end);
        end
        whiskZhold = cat(3, whiskZhold, whiskS_Vals);
    end
    whiskT{w,1} = (SpecData.oneSec.T/whiskBinSize) - offset;
    whiskF{w,1} = SpecData.oneSec.F;
    whiskZhold_all{w,1} = whiskZhold;
end

% Average the different whisking criteria across days
for a = 1:length(whiskZhold_all)
    whiskS{a,1} = mean(whiskZhold_all{a,1}, 3);
end

%% Determine how long each vessel was imaged on this particular day, as well as its resting baseline diameter
for a = 1:length(uniqueVesselIDs)
    uvID = uniqueVesselIDs{a,1};
    t = 1;
    for b = 1:size(specDataFiles,1)
        [~,~,~,vID,~] = GetFileInfo2_SlowOscReview2019(specDataFiles(b,:));
        if strcmp(uvID, vID)
            timePerVessel{a,1} = t*trialDuration;
            t = t+1;
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

%% Save the results.
ComparisonData.(animalID).WhiskEvokedAvgs.vesselData = whiskCritMeans.data;
ComparisonData.(animalID).WhiskEvokedAvgs.vesselIDs = uniqueVesselIDs;
ComparisonData.(animalID).WhiskEvokedAvgs.LFP.T = whiskT;
ComparisonData.(animalID).WhiskEvokedAvgs.LFP.F = whiskF;
ComparisonData.(animalID).WhiskEvokedAvgs.LFP.S = whiskS;
ComparisonData.(animalID).tblVals = tblVals;
cd ..

end
