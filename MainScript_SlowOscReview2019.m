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
multiWaitbar_SlowOscReview2019( 'CloseAll' );

FigOne_SlowOscReview2019(ComparisonData)

FigTwo_SlowOscReview2019(ComparisonData)

FigThree_SlowOscReview2019(ComparisonData)

SuppFigOne_SlowOscReview2019(ComparisonData)

SuppFigTwo_SlowOscReview2019(ComparisonData)

SuppFigThree_SlowOscReview2019(ComparisonData)

end

function [ComparisonData] = AnalyzeData()
%% control for mac/pc differences in filepathing
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
for a = 1:length(animalIDs)
    [ComparisonData] = AnalyzeEvokedResponses_SlowOscReview2019(animalIDs{1,a}, ComparisonData);
    GT_multiWaitbar('Analyzing whisking-evoked data', a/length(animalIDs));
end

%% BLOCK PURPOSE: [2]
for b = 1:length(animalIDs)
    [ComparisonData] = AnalyzeXCorr_SlowOscReview2019(animalIDs{1,b}, ComparisonData);
    GT_multiWaitbar('Analyzing cross correlation', b/length(animalIDs));
end

%% BLOCK PURPOSE: [3]
for c = 1:length(animalIDs)
    [ComparisonData] = AnalyzeCoherence_SlowOscReview2019(animalIDs{1,c}, ComparisonData);
    GT_multiWaitbar('Analyzing coherence', c/length(animalIDs));
end

%% BLOCK PURPOSE: [4]
for d = 1:length(animalIDs)
    [ComparisonData] = AnalyzePowerSpectrum_SlowOscReview2019(animalIDs{1,d}, ComparisonData);
    GT_multiWaitbar('Analyzing power spectra', d/length(animalIDs));
end

end

function GenerateSingleFigures_SlowOscReview2019

if nargin == 0
    fileNames = '';
else
    fileNames = uigetfile('*_MergedData.mat', 'MultiSelect', 'on');
end

for a = 1:length(fileNames)
    
    if iscell(fileNames) == 1
        indFile = fileNames{a};
    else
        indFile = fileName;
    end
    
    load(indFile)
    disp(['Analyzing single trial figure ' num2str(f) ' of ' num2str(size(mergedDataFiles, 1)) '...']); disp(' ');
    [animalID, fileDate, fileID, vesselID, ~] = GetFileInfo2_SlowOscReview2019(indFile);
    strDay = ConvertDate(fileDate);

    %% BLOCK PURPOSE: Filter the whisker angle and identify the solenoid timing and location.
    % Setup butterworth filter coefficients for a 10 Hz lowpass based on the sampling rate (150 Hz).
    [B, A] = butter(4, 10/(30/2), 'low');
    filteredWhiskerAngle = filtfilt(B, A, MergedData.data.Whisker_Angle);
    filteredForceSensor = filtfilt(B, A, MergedData.data.forceSensorM);
    binWhiskers = MergedData.data.binWhiskerAngle;
    binForce = MergedData.data.binForceSensorM;

    %% CBV data - normalize and then lowpass filer
    vesselDiameter = MergedData.data.vesselDiameter;
    normVesselDiameter = (vesselDiameter - RestingBaselines.(vesselID).(strDay).vesselDiameter.baseLine) ./ (RestingBaselines.(vesselID).(strDay).vesselDiameter.baseLine);
    [D, C] = butter(4, 1/(20/2), 'low');
    filteredVesselDiameter = (filtfilt(D, C, normVesselDiameter))*100;

    %% Neural spectrograms
    S = SpectrogramData.FiveSec.S{f, 1};
    S_Norm = SpectrogramData.FiveSec.S_Norm{f, 1};
    T = SpectrogramData.FiveSec.T{f, 1};
    F = SpectrogramData.FiveSec.F{f, 1};
    
    %% Yvals for behavior Indices
    whisking_YVals = 1.10*max(filteredVesselDiameter)*ones(size(binWhiskers));
    force_YVals = 1.20*max(filteredVesselDiameter)*ones(size(binForce));

    %% Figure
    singleTrialFig = figure;
    ax1 = subplot(4,1,1);
    plot((1:length(filteredForceSensor))/30, filteredForceSensor, 'color', colors('sapphire'))
    xlim([0 280])
    title({[animalID ' Two-photon behavioral characterization and vessel ' vesselID ' diameter changes for ' fileID], 'Force sensor and EMG'})
    xlabel('Time (sec)')
    ylabel('Force Sensor (Volts)')
    
    yyaxis right
    plot((1:length(filteredEMG))/30, filteredEMG, 'color', colors('harvest gold'));
    ylabel('EMG (Volts)')
    legend('Force Sensor', 'EMG')
    
    ax2 = subplot(4,1,2:3);
    yyaxis right
    plot((1:length(filteredWhiskerAngle))/30, -filteredWhiskerAngle, 'color', colors('ash grey'))
    xlim([0 280])
    ylabel('Angle (deg)')
    ylim([-10 60])
    
    yyaxis left
    plot((1:length(filteredVesselDiameter))/20, filteredVesselDiameter, 'color', colors('dark candy apple red'))
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
    scatter((1:length(binForce))/30, forceInds, '.', 'MarkerEdgeColor', colors('rich black'));
    scatter((1:length(binWhiskers))/30, whiskInds, '.', 'MarkerEdgeColor', colors('sapphire'));
    xlim([0 280])
    ylim([(min(filteredVesselDiameter))-0.1 (max(filteredVesselDiameter))*1.3])
    title('Vessel diameter in response to behavior events')
    xlabel('Time (sec)')
    ylabel('% change (diameter)')
    legend('Whisker angle', 'Vessel diameter', 'Binarized movement events', 'binarized whisking events')
    
    ax3 = subplot(4,1,4);
    imagesc(T,F,S_Norm)
    axis xy
    caxis([-1 2])
    linkaxes([ax1 ax2 ax3], 'x')
    title('Hippocampal (LFP) spectrogram, caxis([-1 2])')
    xlabel('Time (sec)')
    ylabel('Frequency (Hz)')

    %% Save the file to directory.
    [pathstr, ~, ~] = fileparts(cd);
    dirpath = [pathstr '/Figures/Single Trial Figures/'];

    if ~exist(dirpath, 'dir') 
        mkdir(dirpath); 
    end

    savefig(singleTrialFig, [dirpath animalID '_' vesselID '_' fileID '_SingleTrialFig']);
    close(singleTrialFig)



end