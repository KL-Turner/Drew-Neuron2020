function Process2PDataFiles_SlowOscReview2019(labviewDataFiles, mscanDataFiles)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%________________________________________________________________________________________________________________________
%
%   Purpose: Analyze the force sensor and neural bands. Create a threshold for binarized movement/whisking if 
%            one does not already exist.
%________________________________________________________________________________________________________________________
%
%   Inputs: List of LabVIEW and MScan data files.
%
%   Outputs: Saves updates to both files in the current directory.
%
%   Last Revised: March 21st, 2019
%________________________________________________________________________________________________________________________

%% MScan data file analysis
for a = 1:size(mscanDataFiles,1)
    mscanDataFile = mscanDataFiles(a,:);
    load(mscanDataFile);
    % Skip the file if it has already been processed
    if MScanData.notes.checklist.processData == false
        disp(['Analyzing MScan neural bands and analog signals for file number ' num2str(a) ' of ' num2str(size(mscanDataFiles, 1)) '...']); disp(' ');
        animalID = MScanData.notes.animalID;
        imageID = MScanData.notes.imageID;
        date = MScanData.notes.date;
        strDay = ConvertDate_SlowOscReview2019(date);
        
        expectedLength = (MScanData.notes.numberOfFrames/MScanData.notes.frameRate)*MScanData.notes.analogSamplingRate;
        %% Process neural data into its various forms.
        % MUA Band [300 - 3000]
        [MScanData.data.muaPower, MScanData.notes.downSampledFs] = ProcessNeuro_SlowOscReview2019(MScanData, expectedLength, 'MUA', 'rawNeuralData');
        downSampledFs = MScanData.notes.downSampledFs;

        % Gamma Band [40 - 100]
        [MScanData.data.gammaPower, ~] = ProcessNeuro_SlowOscReview2019(MScanData, expectedLength, 'Gam', 'rawNeuralData');
        
        % Beta [13 - 30 Hz]
        [MScanData.data.betaPower, ~] = ProcessNeuro_SlowOscReview2019(MScanData, expectedLength, 'Beta', 'rawNeuralData');
        
        % Alpha [8 - 12 Hz]
        [MScanData.data.alphaPower, ~] = ProcessNeuro_SlowOscReview2019(MScanData, expectedLength, 'Alpha', 'rawNeuralData');
        
        % Theta [4 - 8 Hz]
        [MScanData.data.thetaPower, ~] = ProcessNeuro_SlowOscReview2019(MScanData, expectedLength, 'Theta', 'rawNeuralData');
        
        % Delta [1 - 4 Hz]
        [MScanData.data.deltaPower, ~] = ProcessNeuro_SlowOscReview2019(MScanData, expectedLength, 'Delta', 'rawNeuralData');
        
        %% Downsample and binarize the force sensor.
        trimmedForceM = MScanData.data.forceSensor(1:min(expectedLength, length(MScanData.data.forceSensor)));
        
        % Filter then downsample the Force Sensor waveform to desired frequency
        filtThreshold = 20;
        filtOrder = 2;
        [z, p, k] = butter(filtOrder, filtThreshold/(MScanData.notes.analogSamplingRate/2), 'low');
        [sos, g] = zp2sos(z, p, k);
        filtForceSensorM = filtfilt(sos, g, trimmedForceM);
        MScanData.data.dsForceSensorM = resample(filtForceSensorM, downSampledFs, MScanData.notes.analogSamplingRate);
        
        % Binarize the force sensor waveform
        threshfile = dir('*_Thresholds.mat');
        if ~isempty(threshfile)
            load(threshfile.name)
        end
        
        [ok] = CheckForThreshold_SlowOscReview2019(['binarizedForceSensor_' strDay], animalID);
        
        if ok == 0
            [forceSensorThreshold] = CreateForceSensorThreshold_SlowOscReview2019(MScanData.data.dsForceSensorM);
            Thresholds.(['binarizedForceSensor_' strDay]) = forceSensorThreshold;
            save([animalID '_Thresholds.mat'], 'Thresholds');
        end
        
        MScanData.data.binForceSensorM = BinarizeForceSensor_SlowOscReview2019(MScanData.data.dsForceSensorM, Thresholds.(['binarizedForceSensor_' strDay]));
        
        %% Save the data, set checklist to true
        MScanData.notes.checklist.processData = true;
        save([animalID '_' date '_' imageID '_MScanData'], 'MScanData')
    else
        disp([mscanDataFile ' has already been processed. Continuing...']); disp(' ');
    end
end


%% LabVIEW data file analysis
for b = 1:size(labviewDataFiles,1)
    labviewDataFile = labviewDataFiles(b,:);
    load(labviewDataFile);
    if LabVIEWData.notes.checklist.processData == false
        disp(['Analyzing LabVIEW analog signals and whisker angle for file number ' num2str(b) ' of ' num2str(size(labviewDataFiles, 1)) '...']); disp(' ');
        [animalID, hem, fileDate, fileID] = GetFileInfo_SlowOscReview2019(labviewDataFile);
        strDay = ConvertDate_SlowOscReview2019(fileDate);
        expectedLength = LabVIEWData.notes.trialDuration_Seconds*LabVIEWData.notes.analogSamplingRate_Hz;

        %% Patch and binarize the whisker angle and set the resting angle to zero degrees.
        [patchedWhisk] = PatchWhiskerAngle_SlowOscReview2019(LabVIEWData.data.whiskerAngle, LabVIEWData.notes.whiskerCamSamplingRate_Hz, LabVIEWData.notes.trialDuration_Seconds, LabVIEWData.notes.droppedWhiskerCamFrameIndex);
        
        % Create filter for whisking/movement
        downSampledFs = 30;
        filtThreshold = 20;
        filtOrder = 2;
        [z, p, k] = butter(filtOrder, filtThreshold/(LabVIEWData.notes.whiskerCamSamplingRate_Hz/2), 'low');
        [sos, g] = zp2sos(z, p, k);
        filteredWhiskers = filtfilt(sos, g, patchedWhisk - mean(patchedWhisk));
        resampledWhisk = resample(filteredWhiskers, downSampledFs, LabVIEWData.notes.whiskerCamSamplingRate_Hz);
        
        % Binarize the whisker waveform (wwf)
        threshfile = dir('*_Thresholds.mat');
        if ~isempty(threshfile)
            load(threshfile.name)
        end
        
        [ok] = CheckForThreshold_SlowOscReview2019(['binarizedWhiskersLower_' strDay], animalID);
        
        if ok == 0
            [whiskersThresh1, whiskersThresh2] = CreateWhiskThreshold_SlowOscReview2019(resampledWhisk, downSampledFs);
            Thresholds.(['binarizedWhiskersLower_' strDay]) = whiskersThresh1;
            Thresholds.(['binarizedWhiskersUpper_' strDay]) = whiskersThresh2;
            save([animalID '_Thresholds.mat'], 'Thresholds');
        end
        
        load([animalID '_Thresholds.mat']);
        binWhisk = BinarizeWhiskers_SlowOscReview2019(resampledWhisk, downSampledFs, Thresholds.(['binarizedWhiskersLower_' strDay]), Thresholds.(['binarizedWhiskersUpper_' strDay]));
        [linkedBinarizedWhiskers] = LinkBinaryEvents_SlowOscReview2019(gt(binWhisk,0), [round(downSampledFs/3), 0]);
        inds = linkedBinarizedWhiskers == 0;
        restAngle = mean(resampledWhisk(inds));
        
        LabVIEWData.data.dsWhiskerAngle = resampledWhisk - restAngle;
        LabVIEWData.data.binWhiskerAngle = binWhisk;
        
        %% Downsample and binarize the force sensor.
        trimmedForceL = LabVIEWData.data.forceSensor(1:min(expectedLength, length(LabVIEWData.data.forceSensor)));
        
        % Filter then downsample the Force Sensor waveform to desired frequency
        [z, p, k] = butter(filtOrder, filtThreshold/(LabVIEWData.notes.analogSamplingRate_Hz/2), 'low');
        [sos, g] = zp2sos(z, p, k);
        filtForceSensorL = filtfilt(sos, g, trimmedForceL);
        
        LabVIEWData.data.dsForceSensorL = resample(filtForceSensorL, downSampledFs, LabVIEWData.notes.analogSamplingRate_Hz);
        
        % Binarize the force sensor waveform
        [ok] = CheckForThreshold_SlowOscReview2019(['binarizedForceSensor_' strDay], animalID);
        
        if ok == 0
            [forceSensorThreshold] = CreateForceSensorThreshold_SlowOscReview2019(LabVIEWData.data.dsForceSensorL);
            Thresholds.(['binarizedForceSensor_' strDay]) = forceSensorThreshold;
            save([animalID '_Thresholds.mat'], 'Thresholds');
        end
        
        LabVIEWData.data.binForceSensorL = BinarizeForceSensor_SlowOscReview2019(LabVIEWData.data.dsForceSensorL, Thresholds.(['binarizedForceSensor_' strDay]));
        
        %% Save the data, set checklist to true
        LabVIEWData.notes.checklist.processData = true;
        save([animalID '_' hem '_' fileID '_LabVIEWData'], 'LabVIEWData')
    else
        disp([labviewDataFile ' has already been processed. Continuing...']); disp(' ');     
    end
end

end

