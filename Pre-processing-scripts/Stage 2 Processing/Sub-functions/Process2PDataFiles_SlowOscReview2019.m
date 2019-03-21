function Process2PDataFiles_SlowOscReview2019(labviewDataFiles, mscanDataFiles)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%________________________________________________________________________________________________________________________
%
%   Purpose:
%________________________________________________________________________________________________________________________
%
%   Inputs:
%
%   Outputs:
%
%   Last Revised: February 29th, 2019
%________________________________________________________________________________________________________________________

%% MScan data file analysis
for f = 1:size(mscanDataFiles, 1)
    %% Find offset between the two force sensor signals using the cross correlation
    MScanDataFile = mscanDataFiles(f, :);
    load(MScanDataFile);
    if MScanData.Notes.checklist.processData == false
        disp(['Analyzing MScan neural bands and analog signals for file number ' num2str(f) ' of ' num2str(size(mscanDataFiles, 1)) '...']); disp(' ');
        animalID = MScanData.Notes.animalID;
        imageID = MScanData.Notes.imageID;
        date = MScanData.Notes.date;
        strDay = ConvertDate(date);
        
        expectedLength = (MScanData.Notes.numberOfFrames/MScanData.Notes.frameRate)*MScanData.Notes.MScan_analogSamplingRate;
        %% Process neural data into its various forms.
        % MUA Band [300 - 3000]
        [MScanData.Data.MUA_Power, MScanData.Notes.MScan.multiUnitSamplingRate] = ...
            ProcessNeuro_2P(MScanData, expectedLength, 'MUApower', 'MScan_Neural_Data');
        
        % Gamma Band [40 - 100]
        [MScanData.Data.GammaBand_Power, MScanData.Notes.MScan.gammaBandSamplingRate] = ...
            ProcessNeuro_2P(MScanData, expectedLength, 'Gam', 'MScan_Neural_Data');
        
        % Beta [13 - 30 Hz]
        [MScanData.Data.BetaBand_Power, MScanData.Notes.MScan.betaBandSamplingRate] = ...
            ProcessNeuro_2P(MScanData, expectedLength, 'Beta', 'MScan_Neural_Data');
        
        % Alpha [8 - 12 Hz]
        [MScanData.Data.AlphaBand_Power, MScanData.Notes.MScan.alphaBandSamplingRate] = ...
            ProcessNeuro_2P(MScanData, expectedLength, 'Alpha', 'MScan_Neural_Data');
        
        % Theta [4 - 8 Hz]
        [MScanData.Data.ThetaBand_Power, MScanData.Notes.MScan.thetaBandSamplingRate] = ...
            ProcessNeuro_2P(MScanData, expectedLength, 'Theta', 'MScan_Neural_Data');
        
        % Delta [1 - 4 Hz]
        [MScanData.Data.DeltaBand_Power, MScanData.Notes.MScan.deltaBandSamplingRate] = ...
            ProcessNeuro_2P(MScanData, expectedLength, 'Delta', 'MScan_Neural_Data');
        
        %% Downsample and binarize the force sensor.
        % Trim any additional data points for resample
        expectedLength = MScanData.Notes.MScan_analogSamplingRate*(MScanData.Notes.numberOfFrames/MScanData.Notes.frameRate);
        trimmedForce = MScanData.Data.MScan_Force_Sensor(1:min(expectedLength, length(MScanData.Data.MScan_Force_Sensor)));
        
        % Filter then downsample the Force Sensor waveform to desired frequency
        downSampledFs = 30;   % Downsample to CBV Camera Fs
        forceSensorFilterThreshold = 20;
        forceSensorFilterOrder = 2;
        [z, p, k] = butter(forceSensorFilterOrder, forceSensorFilterThreshold / (MScanData.Notes.MScan_analogSamplingRate / 2), 'low');
        [sos, g] = zp2sos(z, p, k);
        filteredForceSensor_M = filtfilt(sos, g, trimmedForce);
        
        MScanData.Data.dsForce_Sensor_M = resample(filteredForceSensor_M, downSampledFs, MScanData.Notes.MScan_analogSamplingRate);
        MScanData.Notes.downsampledFs = downSampledFs;
        
        % Binarize the force sensor waveform
        threshfile = dir('*_Thresholds.mat');
        if ~isempty(threshfile)
            load(threshfile.name)
        end
        
        [ok] = CheckForThreshold(['binarizedForceSensor_' strDay], animalID);
        
        if ok == 0
            [forceSensorThreshold] = CreateForceSensorThreshold_SlowOscReview2019(MScanData.Data.dsForce_Sensor_M);
            Thresholds.(['binarizedForceSensor_' strDay]) = forceSensorThreshold;
            save([animalID '_Thresholds.mat'], 'Thresholds');
        end
        
        MScanData.Data.binForce_Sensor_M = BinarizeForceSensor_SlowOscReview2019(MScanData.Data.dsForce_Sensor_M, Thresholds.(['binarizedForceSensor_' strDay]));
        
        %% Save the data, set checklist to true
        MScanData.Notes.checklist.processData = true;
        save([animalID '_' date '_' imageID '_MScanData'], 'MScanData')
    end
end


%% LabVIEW data file analysis
for f = 1:size(labviewDataFiles, 1)
    %% Find offset between the two force sensor signals using the cross correlation
    labviewDataFile = labviewDataFiles(f, :);
    load(labviewDataFile);
    if LabVIEWData.Notes.checklist.processData == false
        disp(['Analyzing LabVIEW analog signals and whisker angle for file number ' num2str(f) ' of ' num2str(size(labviewDataFiles, 1)) '...']); disp(' ');
        [animalID, hem, fileDate, fileID] = GetFileInfo_SlowOscReview2019(labviewDataFile);
        strDay = ConvertDate(fileDate);
        expectedLength = LabVIEWData.Notes.trialDuration_Seconds*LabVIEWData.Notes.analogSamplingRate;

        %% Binarize the whisker angle and set the resting angle to zero degrees.
        % Trim any additional frames for resample
        whiskerAngle = LabVIEWData.Data.WhiskerAngle;
        [patchedWhiskerAngle] = PatchWhiskerAngle(whiskerAngle, LabVIEWData.Notes.whiskerCamSamplingRate, LabVIEWData.Notes.trialDuration_Seconds, LabVIEWData.Notes.droppedWhiskerCamFrameIndex);
        
        % Create filter for whisking/movement
        downSampledFs = 30;   % Downsample to CBV Camera Fs
        whiskerFilterThreshold = 20;
        whiskerFilterOrder = 2;
        [z, p, k] = butter(whiskerFilterOrder, whiskerFilterThreshold/(LabVIEWData.Notes.whiskerCamSamplingRate/2), 'low');
        [sos, g] = zp2sos(z, p, k);
        filteredWhiskers = filtfilt(sos, g, patchedWhiskerAngle - mean(patchedWhiskerAngle));
        resampledWhiskers = resample(filteredWhiskers, downSampledFs, LabVIEWData.Notes.whiskerCamSamplingRate);
        
        % Binarize the whisker waveform (wwf)
        threshfile = dir('*_Thresholds.mat');
        if ~isempty(threshfile)
            load(threshfile.name)
        end
        
        [ok] = CheckForThreshold(['binarizedWhiskersLower_' strDay], animalID);
        
        if ok == 0
            [whiskersThresh1, whiskersThresh2] = CreateWhiskThreshold_SlowOscReview2019(resampledWhiskers, downSampledFs);
            Thresholds.(['binarizedWhiskersLower_' strDay]) = whiskersThresh1;
            Thresholds.(['binarizedWhiskersUpper_' strDay]) = whiskersThresh2;
            save([animalID '_Thresholds.mat'], 'Thresholds');
        end
        
        load([animalID '_Thresholds.mat']);
        binarizedWhiskers = BinarizeWhiskers_SlowOscReview2019(resampledWhiskers, downSampledFs, Thresholds.(['binarizedWhiskersLower_' strDay]), Thresholds.(['binarizedWhiskersUpper_' strDay]));
        [linkedBinarizedWhiskers] = LinkBinaryEvents_SlowOscReview2019(gt(binarizedWhiskers,0), [round(downSampledFs/3), 0]);
        
        inds = linkedBinarizedWhiskers == 0;
        restAngle = mean(resampledWhiskers(inds));
        
        LabVIEWData.Data.dsWhisker_Angle = resampledWhiskers - restAngle;
        LabVIEWData.Data.binWhisker_Angle = binarizedWhiskers;
        LabVIEWData.Notes.downsampledWhiskerSamplingRate = downSampledFs;
        
        %% Downsample and binarize the force sensor.
        % Trim any additional data points for resample
        trimmed_lvForce = LabVIEWData.Data.Force_Sensor(1:min(expectedLength, length(LabVIEWData.Data.Force_Sensor)));
        % Filter then downsample the Force Sensor waveform to desired frequency
        downSampledFs = 30;   % Downsample to CBV Camera Fs
        forceSensorFilterThreshold = 20;
        forceSensorFilterOrder = 2;
        [z, p, k] = butter(forceSensorFilterOrder, forceSensorFilterThreshold/(LabVIEWData.Notes.analogSamplingRate/2), 'low');
        [sos, g] = zp2sos(z, p, k);
        filteredForceSensor_L = filtfilt(sos, g, trimmed_lvForce);
        
        LabVIEWData.Data.dsForce_Sensor_L = resample(filteredForceSensor_L, downSampledFs, LabVIEWData.Notes.analogSamplingRate);
        LabVIEWData.Notes.downSampledFs = downSampledFs;
        
        % Binarize the force sensor waveform
        [ok] = CheckForThreshold(['binarizedForceSensor_' strDay], animalID);
        
        if ok == 0
            [forceSensorThreshold] = CreateForceSensorThreshold_SlowOscReview2019(LabVIEWData.Data.dsForce_Sensor_L);
            Thresholds.(['binarizedForceSensor_' strDay]) = forceSensorThreshold;
            save([animalID '_Thresholds.mat'], 'Thresholds');
        end
        
        LabVIEWData.Data.binForce_Sensor_L = BinarizeForceSensor_SlowOscReview2019(LabVIEWData.Data.dsForce_Sensor_L, Thresholds.(['binarizedForceSensor_' strDay]));
        
        %% Save the data, set checklist to true
        LabVIEWData.Notes.checklist.processData = true;
        save([animalID '_' hem '_' fileID '_LabVIEWData'], 'LabVIEWData')
    end
end

end
