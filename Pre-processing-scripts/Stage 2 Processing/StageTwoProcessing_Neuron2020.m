%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: 1) Pull vessel notes from Excel sheet.
%            2) Analyze vessel diameter.
%            3) Analyze neural bands, force sensors, and whisker motion.
%            4) Correct LabVIEW time offset.
%            5) Combine LabVIEWData and MScan Data files to ceate MergedData. 
%________________________________________________________________________________________________________________________

%% BLOCK PURPOSE: [0] Load the script's necessary variables and data structures.
% Clear the workspace variables and command window.
clc;
clear;
close all
disp('Analyzing Block [0] Preparing the workspace and loading variables.'); disp(' ')
msExcelDir = dir('*.xlsx');
msExcelFile = {msExcelDir.name}';
msExcelFile = char(msExcelFile);

%% BLOCK PURPOSE: [1] Use ms Excel sheet to create MScanData.mat files with vessel information.
disp('Analyzing Block [1] Pulling vessel notes from Excel sheet.'); disp(' ')
Analyze2PDataNotes_Neuron2020(msExcelFile);

%% BLOCK PURPOSE: [2] Analyze vessel diameter and add it to MScanData.mat.
disp('Analyzing Block [2] Analyzing vessel diameter.'); disp(' ')
mscanDirectory = dir('*_MScanData.mat');
mscanDataFiles = {mscanDirectory.name}';
mscanDataFiles = char(mscanDataFiles);
Analyze2PDiameter_Neuron2020(mscanDataFiles);

%% BLOCK PURPOSE: [3] Process neural, whiskers, and force sensor data.
disp('Analyzing Block [3] Analyzing neural bands, force sensors, and whiskers.'); disp(' ')
labviewDirectory = dir('*_LabVIEWData.mat');
labviewDataFiles = {labviewDirectory.name}';
labviewDataFiles = char(labviewDataFiles);
[animalID,~,~,~] = GetFileInfo_Neuron2020(labviewDataFiles(1,:));
Process2PDataFiles_Neuron2020(labviewDataFiles,mscanDataFiles)

%% BLOCK PURPOSE: [4] Correct the offset between the MScan and LabVIEW acquisiton.
disp('Analyzing Block [4] Correcting LabVIEW time offset.'); disp(' ')
if strcmp(animalID,'T72') || strcmp(animalID,'T73') || strcmp(animalID,'T74') || strcmp(animalID,'T75') || strcmp(animalID,'T76')
    trimTime = 10;   % sec
elseif strcmp(animalID,'T80') || strcmp(animalID,'T81') || strcmp(animalID,'T82') || strcmp(animalID,'T83')
    trimTime = 30;   % sec
end
CorrectLabVIEWOffset_Neuron2020(labviewDataFiles,mscanDataFiles,trimTime)

%% BLOCK PURPOSE: [5] Combine the MScan and LabVIEW structures into one.
disp('Analyzing Block [5] Combing LabVIEWData and MScan Data files to create MergedData.'); disp(' ')
CombineLabVIEWMScanFiles_Neuron2020(labviewDataFiles,mscanDataFiles)

disp('Two Photon Stage Two Processing - Complete.'); disp(' ')
 