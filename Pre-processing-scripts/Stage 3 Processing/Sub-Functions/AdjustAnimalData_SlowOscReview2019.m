%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%_________________________________________________________________________________________________________________________
%
%   Purpose: Adjusts the data for animals T82, T83 to have equal sampling rates
%________________________________________________________________________________________________________________________
%
%   Inputs: Data structures for T82 and T83
%
%   Outputs: Downsampled vessel data from 20 Hz to 5 Hz
%
%   Last Revised: May 29th, 2019
%________________________________________________________________________________________________________________________

mergedDirectory = dir('*_MergedData.mat');
mergedDataFiles = {mergedDirectory.name}';
mergedDataFiles = char(mergedDataFiles);
p2Fs = 20;
dsFs = 5;

for a = 1:size(mergedDataFiles, 1)
    mergedDataFile = mergedDataFiles(a, :);
    load(mergedDataFile)    
    vesselData = MergedData.data.vesselDiameter;
    sampleMean = mean(vesselData(1:5));
    rsVesselData = resample((vesselData - sampleMean), dsFs, p2Fs);
    MergedData.data.vesselDiameter = rsVesselData + sampleMean;
    MergedData.notes.p2Fs = 5;
    save(mergedDataFile, 'MergedData')
end
