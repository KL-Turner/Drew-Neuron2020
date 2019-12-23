function [] = MainScript_Neuron2020()
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

clear; clc; close all
%% Make sure the current directory is 'TurnerFigs-Neuron2020' and that the code repository is present.
currentFolder = pwd;
addpath(genpath(currentFolder));
fileparts = strsplit(currentFolder,filesep);
if ismac
    rootfolder = fullfile(filesep,fileparts{1:end},'Processed Data');
else
    rootfolder = fullfile(fileparts{1:end},'Processed Data');
end
% Add root folder to Matlab's working directory.
addpath(genpath(rootfolder))

% Verify that the User is in the correct working directory. Toss an error msg & end the function if not.
if ~strcmp(fileparts(end), 'Kleinfeld_Review_Neuron2020_Turner_ProcData') && ~strcmp(fileparts(end), 'TurnerFigs-Neuron2020-master') && ~strcmp(fileparts(end), 'TurnerFigs-Neuron2020')
    message = 'The current folder does not appear to be Kleinfeld_Review_Neuron2020_Turner_ProcData or TurnerFigs-Neuron2020-master, please cd to the correct folder and re-run';
    title = 'Incorrect Directory';
    waitfor(msgbox(message,title,'error'));
    return
end

%% Run the data analysis. The progress bars will show the analysis progress.
dataSummary = dir('ComparisonData.mat');
% If the analysis structure has already been created, load it and skip the analysis.
if ~isempty(dataSummary)
    load(dataSummary.name);
    disp('Loading analysis results and generating figures...'); disp(' ')
else
    multiWaitbar_Neuron2020('Analyzing cross correlation',0,'Color',[0.720000 0.530000 0.040000]); pause(0.25);
    multiWaitbar_Neuron2020('Analyzing coherence',0,'Color',[0.720000 0.530000 0.040000]); pause(0.25);
    % Run analysis and output a structure containing all the analyzed data.
    [ComparisonData] = AnalyzeData_Neuron2020;
    multiWaitbar_Neuron2020('CloseAll');
end

%% Informational figures with function dependencies for the various analysis and the time per vessel.
% To view individual summary figures, change the value of line 72 to false. You will then be prompted to manually select
% any number of figures (CTL-A for all) inside any of the five folders. You can only do one animal at a time.
functionNames = {'MainScript_Neuron2020', 'StageOneProcessing_Neuron2020'...
    'StageTwoProcessing_Neuron2020','StageThreeProcessing_Neuron2020'};
functionList = {};
for a = 1:length(functionNames)
    [functionList] = GetFuncDependencies_Neuron2020(a,functionNames{1,a},functionNames,functionList);
end
DetermineVesselStatistics_Neuron2020(ComparisonData);

% Create single trial summary figures. selectFigs = false displays the one used for representative example.
selectFigs = false;   % set to true to manually select other figure(s).
GenerateSingleFigures_Neuron2020(selectFigs)

%% Individual figures can be re-run after the analysis has completed.
Fig7_Neuron2020(ComparisonData)
TempCohXCorrFig_Neuron2020(ComparisonData)

disp('MainScript Analysis - Complete'); disp(' ')
end

function [ComparisonData] = AnalyzeData_Neuron2020()
animalIDs = {'T72','T73','T74','T75','T76','T80','T81','T82','T83'};   % list of animal IDs
ComparisonData = [];   % pre-allocate the results structure as empty

%% BLOCK PURPOSE: [1] Analyze the cross-correlation between abs(whisker acceleration) and vessel diameter.
for b = 1:length(animalIDs)
    [ComparisonData] = AnalyzeXCorr_Neuron2020(animalIDs{1,b},ComparisonData);
    multiWaitbar_Neuron2020('Analyzing cross correlation','Value',b/length(animalIDs));
end

% BLOCK PURPOSE: [2] Analyze the spectral coherence between abs(whisker acceleration) and vessel diameter.
for c = 1:length(animalIDs)
    [ComparisonData] = AnalyzeCoherence_Neuron2020(animalIDs{1,c},ComparisonData);
    multiWaitbar_Neuron2020('Analyzing coherence','Value',c/length(animalIDs));
end

answer = questdlg('Would you like to save the analysis results structure?','','yes','no','yes');
if strcmp(answer,'yes')
    save('ComparisonData.mat','ComparisonData')
end

disp('Loading analysis results and generating figures...'); disp(' ')

end

function [] = GenerateSingleFigures_Neuron2020(selectFigs)
if selectFigs == true
    [fileNames,path] = uigetfile('*_MergedData.mat','MultiSelect','on');
    cd(path)
    
    % Load the RestingBaselines structure from this animal
    baselineDirectory = dir('*_RestingBaselines.mat');
    baselineDataFile = {baselineDirectory.name}';
    baselineDataFile = char(baselineDataFile);
    load(baselineDataFile,'-mat')
    
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
        load(indFile,'-mat');
        if length(fileNames) > 1
            disp(['Analyzing single trial figure ' num2str(a) ' of ' num2str(size(fileNames,2)) '...']); disp(' ');
        end
        [animalID,fileDate,fileID,vesselID,~] = GetFileInfo2_Neuron2020(indFile);
        strDay = ConvertDate_Neuron2020(fileDate);
        
        %% BLOCK PURPOSE: Filter the whisker angle and identify the solenoid timing and location.
        % Setup butterworth filter coefficients for a 10 Hz lowpass based on the sampling rate (30 Hz).
        [B, A] = butter(3,10/(MergedData.notes.dsFs/2),'low');
        filteredWhiskerAngle = filtfilt(B,A,MergedData.data.whiskerAngle);
        filtForceSensor = filtfilt(B,A,MergedData.data.forceSensorM);
        binWhiskers = MergedData.data.binWhiskerAngle;
        binForce = MergedData.data.binForceSensorM;
        
        %% CBV data - normalize and then lowpass filer
        % Setup butterworth filter coefficients for a 1 Hz lowpass based on the sampling rate (20 Hz).
        [D, C] = butter(3,1/(MergedData.notes.p2Fs/2),'low');
        vesselDiameter = MergedData.data.vesselDiameter;
        normVesselDiameter = (vesselDiameter - RestingBaselines.(vesselID).(strDay).vesselDiameter.baseLine)./(RestingBaselines.(vesselID).(strDay).vesselDiameter.baseLine);
        filtVesselDiameter = (filtfilt(D,C,normVesselDiameter))*100;
        
        %% Yvals for behavior Indices
        whisking_YVals = 1.10*max(detrend(filtVesselDiameter,'constant'))*ones(size(binWhiskers));
        force_YVals = 1.20*max(detrend(filtVesselDiameter,'constant'))*ones(size(binForce));
        
        %% Figure
        figure;
        ax1 = subplot(3,1,1);
        plot((1:length(filtForceSensor))/MergedData.notes.dsFs,filtForceSensor,'color',colors_Neuron2020('sapphire'))
        title({[animalID ' Two-photon behavioral characterization and vessel ' vesselID ' diameter changes for ' fileID], 'Force sensor and whisker angle'})
        xlabel('Time (sec)')
        ylabel('Force Sensor (Volts)')
        xlim([0 MergedData.notes.trialDuration_Sec])
        yyaxis right
        plot((1:length(filteredWhiskerAngle))/MergedData.notes.dsFs,-filteredWhiskerAngle,'color',colors_Neuron2020('carrot orange'))
        ylabel('Angle (deg)')
        legend('Force sensor', 'Whisker angle')
        xlim([0 MergedData.notes.trialDuration_Sec])
        
        ax2 = subplot(3,1,2:3);
        plot((1:length(filtVesselDiameter))/MergedData.notes.p2Fs,detrend(filtVesselDiameter,'constant'),'color',colors_Neuron2020('dark candy apple red'))
        hold on;
        whiskInds = binWhiskers.*whisking_YVals;
        forceInds = binForce.*force_YVals;
        for x = 1:length(whiskInds)
            if whiskInds(1,x) == 0
                whiskInds(1,x) = NaN;
            end
            
            if forceInds(1,x) == 0
                forceInds(1,x) = NaN;
            end
        end
        scatter((1:length(binForce))/MergedData.notes.dsFs,forceInds,'.','MarkerEdgeColor',colors_Neuron2020('sapphire'));
        scatter((1:length(binWhiskers))/MergedData.notes.dsFs,whiskInds,'.','MarkerEdgeColor',colors_Neuron2020('carrot orange'));
        title('Vessel diameter in response to behaviorial events')
        xlabel('Time (sec)')
        ylabel('% change (diameter)')
        legend('Vessel diameter','Binarized movement events','binarized whisking events')
        xlim([0 MergedData.notes.trialDuration_Sec])
        linkaxes([ax1,ax2],'x')
    end
    cd ..
end

end