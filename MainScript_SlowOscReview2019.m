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
