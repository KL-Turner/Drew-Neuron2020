function [] = MainScript_SlowOscReview2019()
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Generates KLT's main and supplemental figs for the 2019 Slow Oscillations review paper. 
%
%            Scripts used to pre-process the original data are located in the folder "Pre-processing-scripts".
%            Functions that are used in both the analysis and pre-processing are located in the analysis folder.
%________________________________________________________________________________________________________________________
%
%   Inputs: No inputs - this function is intended to be run independently.
%
%   Outputs: - Each main and supplmental figure with its corresponding number and letter in the paper.
%            - Table of the amount of time imaged for each vessel.
%            - List of function dependencies for the various analysis.
%
%   Last Revised: March 23rd, 2019
%________________________________________________________________________________________________________________________

clear; clc; close all
%% Make sure the current directory is 'TurnerFigs-SlowOscReview2019' and that the MainScript/code repository is present.
currentFolder = pwd;
addpath(genpath(currentFolder));
fileparts = strsplit(currentFolder, filesep);
if ismac
    rootfolder = fullfile(filesep, fileparts{1:end}, 'Processed Data');
else
    rootfolder = fullfile(fileparts{1:end}, 'Processed Data');
end
% Add root folder to Matlab's working directory.
addpath(genpath(rootfolder))

% Verify that the User is in the correct working directory. Toss an error msg & end the function if not.
if ~strcmp(fileparts(end),'Kleinfeld_Review2019_Turner_ProcessedData')
    message = 'The current folder does not appear to be Kleinfeld_Review2019_Turner_ProcessedData, please cd to the correct folder and re-run';
    title = 'Incorrect Directory';
    waitfor(msgbox(message,title,'error'));
    return
end

%% Run the data analysis. The progress bars will show the analysis progress.
dataSummary = dir('ComparisonData.mat');
% If the analysis structure has already been created, load it and skip the analysis.
if ~isempty(dataSummary)
    load(dataSummary.name);
    disp('Loading analysis results and re-generating figures...'); disp('')
else
    multiWaitbar_SlowOscReview2019('Analyzing whisking-evoked data', 0, 'Color', [0.720000 0.530000 0.040000]); pause(0.25);
    multiWaitbar_SlowOscReview2019('Analyzing cross correlation', 0, 'Color', [0.720000 0.530000 0.040000]); pause(0.25);
    multiWaitbar_SlowOscReview2019('Analyzing coherence', 0, 'Color', [0.720000 0.530000 0.040000]); pause(0.25);
    multiWaitbar_SlowOscReview2019('Analyzing power spectra', 0, 'Color', [0.720000 0.530000 0.040000]); pause(0.25);
    % Run analysis and output a structure containing all the analyzed data.
    [ComparisonData] = AnalyzeData_SlowOscReview2019;
    multiWaitbar_SlowOscReview2019('CloseAll');
end

%% Informational figures with function dependencies for the various analysis and the time per vessel.
% To view individual summary figures, change the value of line 72 to false. You will then be prompted to manually select
% any number of figures (CTL-A for all) inside any of the five folders. You can only do one animal at a time.
functionNames = {'MainScript_SlowOscReview2019', 'StageOneProcessing_SlowOscReview2019'...
    'StageTwoProcessing_SlowOscReview2019','StageThreeProcessing_SlowOscReview2019'};
functionList = {};
for a = 1:length(functionNames)
    [functionList] = GetFuncDependencies_SlowOscReview2019(a, functionNames{1,a}, functionNames, functionList);
end
DetermineVesselStatistics_SlowOscReview2019(ComparisonData);

% Create single trial summary figures. selectFigs = false displays the one used for representative example.
selectFigs = false;   % set to true to manually select other figure(s).
GenerateSingleFigures_SlowOscReview2019(selectFigs)

%% Individual figures can be re-run after the analysis has completed.
SuppFigFour_SlowOscReview2019(ComparisonData);    % Individual Power Spectra
SuppFigThree_SlowOscReview2019(ComparisonData);   % Individual Coherence
SuppFigTwo_SlowOscReview2019(ComparisonData);     % Individual Cross-correlation
SuppFigOne_SlowOscReview2019(ComparisonData);     % Individual Evoked whisking responses

FigFour_SlowOscReview2019(ComparisonData);        % Avg. Power Spectra
FigThree_SlowOscReview2019(ComparisonData);       % Avg. Coherence
FigTwo_SlowOscReview2019(ComparisonData);         % Avg. Cross-correlation
FigOne_SlowOscReview2019(ComparisonData);         % Avg. Evoked whisking responses

disp('MainScript Analysis - Complete'); disp(' ')
end

function [ComparisonData] = AnalyzeData_SlowOscReview2019()
animalIDs = {'T72', 'T73', 'T74', 'T75', 'T76', 'T80', 'T81', 'T82', 'T82b', 'T83', 'T83b'};   % list of animal IDs
ComparisonData = [];   % pre-allocate the results structure as empty

%% BLOCK PURPOSE: [1] Analyze the whisking-evoked changes in vessel diameter and neural LFP.
for a = 1:length(animalIDs)
    [ComparisonData] = AnalyzeEvokedResponses_SlowOscReview2019(animalIDs{1,a}, ComparisonData);
    multiWaitbar_SlowOscReview2019('Analyzing whisking-evoked data', 'Value', a/length(animalIDs));
end

%% BLOCK PURPOSE: [2] Analyze the cross-correlation between abs(whisker acceleration) and vessel diameter.
for b = 1:length(animalIDs)
    [ComparisonData] = AnalyzeXCorr_SlowOscReview2019(animalIDs{1,b}, ComparisonData);
    multiWaitbar_SlowOscReview2019('Analyzing cross correlation', 'Value', b/length(animalIDs));
end

%% BLOCK PURPOSE: [3] Analyze the spectral coherence between abs(whisker acceleration) and vessel diameter.
for c = 1:length(animalIDs)
    [ComparisonData] = AnalyzeCoherence_SlowOscReview2019(animalIDs{1,c}, ComparisonData);
    multiWaitbar_SlowOscReview2019('Analyzing coherence', 'Value', c/length(animalIDs));
end

%% BLOCK PURPOSE: [4] Analyze the spectral power of abs(whisker acceleration) and vessel diameter.
for d = 1:length(animalIDs)
    [ComparisonData] = AnalyzePowerSpectrum_SlowOscReview2019(animalIDs{1,d}, ComparisonData);
    multiWaitbar_SlowOscReview2019('Analyzing power spectra', 'Value', d/length(animalIDs));
end

answer = questdlg('Would you like to save the analysis results structure?', '', 'yes', 'no', 'yes');
if strcmp(answer, 'yes')
    save('ComparisonData.mat', 'ComparisonData')
end

disp('Loading analysis results and generating figures...'); disp(' ')

end

function [] = GenerateSingleFigures_SlowOscReview2019(selectFigs)
if selectFigs == true
    [fileNames, path] = uigetfile('*_MergedData.mat', 'MultiSelect', 'on');
    cd(path)
else
    fileNames = 'T72_A1_190317_19_21_24_022_MergedData.mat';
    cd('T72')
end

% Load the RestingBaselines structure from this animal
baselineDirectory = dir('*_RestingBaselines.mat');
baselineDataFile = {baselineDirectory.name}';
baselineDataFile = char(baselineDataFile);
load(baselineDataFile, '-mat')

% Control for the case that a single file is selected vs. multiple files
if iscell(fileNames) == 0
    fileName = fileNames;
    fileNames = 1;
end

for a = 1:length(fileNames)
    % Control for the case that a single file is selected vs. multiple files
    if iscell(fileNames) == 1
        indFile = fileNames{1,a};
    else
        indFile = fileName;
    end
    
    % Load specific file and pull relevant file information for normalization and figure labels
    load(indFile, '-mat');
    if length(fileNames) > 1
        disp(['Analyzing single trial figure ' num2str(a) ' of ' num2str(size(fileNames,2)) '...']); disp(' ');
    end
    [animalID, fileDate, fileID, vesselID, imageID] = GetFileInfo2_SlowOscReview2019(indFile);
    strDay = ConvertDate_SlowOscReview2019(fileDate);
    
    %% BLOCK PURPOSE: Filter the whisker angle and identify the solenoid timing and location.
    % Setup butterworth filter coefficients for a 10 Hz lowpass based on the sampling rate (30 Hz).
    [B, A] = butter(4, 10/(MergedData.notes.dsFs/2), 'low');
    filteredWhiskerAngle = filtfilt(B, A, MergedData.data.whiskerAngle);
    filtForceSensor = filtfilt(B, A, MergedData.data.forceSensorM);
    binWhiskers = MergedData.data.binWhiskerAngle;
    binForce = MergedData.data.binForceSensorM;
    
    %% CBV data - normalize and then lowpass filer
    % Setup butterworth filter coefficients for a 1 Hz lowpass based on the sampling rate (20 Hz).
    [D, C] = butter(4, 1/(MergedData.notes.p2Fs/2), 'low');
    vesselDiameter = MergedData.data.vesselDiameter;
    normVesselDiameter = (vesselDiameter - RestingBaselines.(vesselID).(strDay).vesselDiameter.baseLine)./(RestingBaselines.(vesselID).(strDay).vesselDiameter.baseLine);
    filtVesselDiameter = (filtfilt(D, C, normVesselDiameter))*100;
    
    %% Normalized neural spectrogram
    specDataFile = [animalID '_' vesselID '_' fileID '_' imageID '_SpecData.mat'];
    load(specDataFile, '-mat');
    normS = SpecData.fiveSec.normS;
    T = SpecData.fiveSec.T;
    F = SpecData.fiveSec.F;
    
    %% Yvals for behavior Indices
    whisking_YVals = 1.10*max(detrend(filtVesselDiameter, 'constant'))*ones(size(binWhiskers));
    force_YVals = 1.20*max(detrend(filtVesselDiameter, 'constant'))*ones(size(binForce));
    
    %% Figure
    figure;
    ax1 = subplot(4,1,1);
    plot((1:length(filtForceSensor))/MergedData.notes.dsFs, filtForceSensor, 'color', colors_SlowOscReview2019('sapphire'))
    title({[animalID ' Two-photon behavioral characterization and vessel ' vesselID ' diameter changes for ' fileID], 'Force sensor and whisker angle'})
    xlabel('Time (sec)')
    ylabel('Force Sensor (Volts)')
    xlim([0 MergedData.notes.trialDuration_Sec])  
    yyaxis right
    plot((1:length(filteredWhiskerAngle))/MergedData.notes.dsFs, -filteredWhiskerAngle, 'color', colors_SlowOscReview2019('carrot orange'))
    ylabel('Angle (deg)')
    legend('Force sensor', 'Whisker angle')
    xlim([0 MergedData.notes.trialDuration_Sec])

    ax2 = subplot(4,1,2:3);
    plot((1:length(filtVesselDiameter))/MergedData.notes.p2Fs, detrend(filtVesselDiameter, 'constant'), 'color', colors_SlowOscReview2019('dark candy apple red'))
    hold on;
    whiskInds = binWhiskers.*whisking_YVals;
    forceInds = binForce.*force_YVals;
    for x = 1:length(whiskInds)
        if whiskInds(1, x) == 0
            whiskInds(1, x) = NaN;
        end
        
        if forceInds(1, x) == 0
            forceInds(1, x) = NaN;
        end
    end
    scatter((1:length(binForce))/MergedData.notes.dsFs, forceInds, '.', 'MarkerEdgeColor', colors_SlowOscReview2019('sapphire'));
    scatter((1:length(binWhiskers))/MergedData.notes.dsFs, whiskInds, '.', 'MarkerEdgeColor', colors_SlowOscReview2019('carrot orange'));
    title('Vessel diameter in response to behaviorial events')
    xlabel('Time (sec)')
    ylabel('% change (diameter)')
    legend('Vessel diameter', 'Binarized movement events', 'binarized whisking events')
    xlim([0 MergedData.notes.trialDuration_Sec])
    
    ax3 = subplot(4,1,4);
    imagesc(T,F,normS)
    axis xy
    colorbar
    caxis([-0.5 0.75])
    linkaxes([ax1 ax2 ax3], 'x')
    title('Hippocampal (LFP) spectrogram')
    xlabel('Time (sec)')
    ylabel('Frequency (Hz)')
    xlim([0 MergedData.notes.trialDuration_Sec])
    pause(1)
end
cd ..

end