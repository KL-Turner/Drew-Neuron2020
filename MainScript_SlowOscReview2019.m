function [] = MainScript_SlowOscReview2019()
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: 
%
%           Scripts used to pre-process the original data are located in the folder "Pre-processing-scripts". Functions
%                   that are used in both the analysis and pre-processing are located in the analysis folder.
%________________________________________________________________________________________________________________________
%
%   Inputs:
%
%   Outputs:
%
%   Last Revised: March 20th, 2019
%________________________________________________________________________________________________________________________

GT_multiWaitbar('Analyzing whisking-evoked data', 0, 'Color', [0.720000 0.530000 0.040000]); pause(0.25);
GT_multiWaitbar('Analyzing cross correlation', 0, 'Color', [0.720000 0.530000 0.040000]); pause(0.25);
GT_multiWaitbar('Analyzing coherence', 0, 'Color', [0.720000 0.530000 0.040000]); pause(0.25);
GT_multiWaitbar('Analyzing power spectra', 0, 'Color', [0.720000 0.530000 0.040000]); pause(0.25);
[ComparisonData] = AnalyzeData;
multiWaitbar_SlowOscReview2019('CloseAll');

FigOne_SlowOscReview2019(ComparisonData)

FigTwo_SlowOscReview2019(ComparisonData)

FigThree_SlowOscReview2019(ComparisonData)

SuppFigOne_SlowOscReview2019(ComparisonData)

SuppFigTwo_SlowOscReview2019(ComparisonData)

SuppFigThree_SlowOscReview2019(ComparisonData)

end

function [ComparisonData] = AnalyzeData()
%% Control for mac/pc differences in filepathing
currentFolder = pwd;
addpath(genpath(currentFolder));
fileparts = strsplit(currentFolder, filesep);
if ismac
    rootfolder = fullfile(filesep, fileparts{1:end}, 'TurnerFigs-SlowOscReview2019');
else
    rootfolder = fullfile(fileparts{1:end}, 'TurnerFigs-SlowOscReview2019');
end
addpath(genpath(rootfolder))   % add root folder to Matlab's working directory

animalIDs = {'T72', 'T73', 'T74', 'T75', 'T76'};   % list of animal IDs
ComparisonData = [];   % pre-allocate the results structure as empty

%% BLOCK PURPOSE: [1]
% for a = 1:length(animalIDs)
%     [ComparisonData] = AnalyzeEvokedResponses_SlowOscReview2019(animalIDs{1,a}, ComparisonData);
%     GT_multiWaitbar('Analyzing whisking-evoked data', a/length(animalIDs));
% end
%
% %% BLOCK PURPOSE: [2]
% for b = 1:length(animalIDs)
%     [ComparisonData] = AnalyzeXCorr_SlowOscReview2019(animalIDs{1,b}, ComparisonData);
%     GT_multiWaitbar('Analyzing cross correlation', b/length(animalIDs));
% end
%
% %% BLOCK PURPOSE: [3]
% for c = 1:length(animalIDs)
%     [ComparisonData] = AnalyzeCoherence_SlowOscReview2019(animalIDs{1,c}, ComparisonData);
%     GT_multiWaitbar('Analyzing coherence', c/length(animalIDs));
% end
%
% %% BLOCK PURPOSE: [4]
% for d = 1:length(animalIDs)
%     [ComparisonData] = AnalyzePowerSpectrum_SlowOscReview2019(animalIDs{1,d}, ComparisonData);
%     GT_multiWaitbar('Analyzing power spectra', d/length(animalIDs));
% end

%% BLOCK PURPOSE: [5]
selectFigs = true;
GenerateSingleFigures_SlowOscReview2019(selectFigs)

end

function [] = GenerateSingleFigures_SlowOscReview2019(selectFigs)

if selectFigs == true
    [fileNames, path] = uigetfile('*_MergedData.mat', 'MultiSelect', 'on');
    cd(path)
else
    fileNames = '';
end

baselineDirectory = dir('*_RestingBaselines.mat');
baselineDataFile = {baselineDirectory.name}';
baselineDataFile = char(baselineDataFile);
load(baselineDataFile, '-mat')

for a = 1:length(fileNames)
    
    if iscell(fileNames) == 1
        indFile = fileNames{1,a};
    else
        indFile = fileName;
    end
    
    load(indFile, '-mat');
    disp(['Analyzing single trial figure ' num2str(a) ' of ' num2str(size(fileNames,2)) '...']); disp(' ');
    [animalID, fileDate, fileID, vesselID, imageID] = GetFileInfo2_SlowOscReview2019(indFile);
    strDay = ConvertDate(fileDate);
    
    %% BLOCK PURPOSE: Filter the whisker angle and identify the solenoid timing and location.
    % Setup butterworth filter coefficients for a 10 Hz lowpass based on the sampling rate (150 Hz).
    [B, A] = butter(4, 10/(MergedData.notes.dsFs/2), 'low');
    filteredWhiskerAngle = filtfilt(B, A, MergedData.data.whiskerAngle);
    filtForceSensor = filtfilt(B, A, MergedData.data.forceSensorM);
    binWhiskers = MergedData.data.binWhiskerAngle;
    binForce = MergedData.data.binForceSensorM;
    
    %% CBV data - normalize and then lowpass filer
    vesselDiameter = MergedData.data.vesselDiameter;
    normVesselDiameter = (vesselDiameter - RestingBaselines.(vesselID).(strDay).vesselDiameter.baseLine)./(RestingBaselines.(vesselID).(strDay).vesselDiameter.baseLine);
    [D, C] = butter(4, 1/(MergedData.notes.p2Fs/2), 'low');
    filtVesselDiameter = (filtfilt(D, C, normVesselDiameter))*100;
    
    %% Neural spectrograms
    specDataFile = [animalID '_' vesselID '_' fileID '_' imageID '_SpecData.mat'];
    load(specDataFile, '-mat');
    normS = SpecData.fiveSec.normS;
    T = SpecData.fiveSec.T;
    F = SpecData.fiveSec.F;
    
    %% Yvals for behavior Indices
    whisking_YVals = 1.10*max(filtVesselDiameter)*ones(size(binWhiskers));
    force_YVals = 1.20*max(filtVesselDiameter)*ones(size(binForce));
    
    %% Figure
    figure;
    ax1 = subplot(4,1,1);
    plot((1:length(filtForceSensor))/MergedData.notes.dsFs, filtForceSensor, 'color', colors_SlowOscReview2019('sapphire'))
    title({[animalID ' Two-photon behavioral characterization and vessel ' vesselID ' diameter changes for ' fileID], 'Force sensor and whisker angle'})
    xlabel('Time (sec)')
    ylabel('Force Sensor (Volts)')
    xlim([0 MergedData.notes.trialDuration_Sec])
    
    yyaxis right
    plot((1:length(filteredWhiskerAngle))/MergedData.notes.dsFs, -filteredWhiskerAngle, 'color', colors_SlowOscReview2019('ash grey'))
    ylabel('Angle (deg)')
    legend('Force sensor', 'Whisker angle')
    xlim([0 MergedData.notes.trialDuration_Sec])
    
    ax2 = subplot(4,1,2:3);
    plot((1:length(filtVesselDiameter))/MergedData.notes.p2Fs, filtVesselDiameter, 'color', colors_SlowOscReview2019('dark candy apple red'))
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
    scatter((1:length(binForce))/MergedData.notes.dsFs, forceInds, '.', 'MarkerEdgeColor', colors_SlowOscReview2019('rich black'));
    scatter((1:length(binWhiskers))/MergedData.notes.dsFs, whiskInds, '.', 'MarkerEdgeColor', colors_SlowOscReview2019('sapphire'));
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
end

end