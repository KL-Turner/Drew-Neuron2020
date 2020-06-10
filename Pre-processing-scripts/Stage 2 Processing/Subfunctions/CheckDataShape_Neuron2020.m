function [] = CheckDataShape_Neuron2020(mergedDataFiles)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Checks the shape of each data type and sets it to 1 x n as later functions rely on this consistency
%________________________________________________________________________________________________________________________

for a = 1:size(mergedDataFiles,1)
    mergedDataFile = mergedDataFiles(a,:);
    load(mergedDataFile)
    dataTypes = fieldnames(MergedData.data);
    for b = 1:length(dataTypes)
        typeShape = size(MergedData.data.(dataTypes{b,1}));
        if typeShape(1) ~= 1
            MergedData.data.(dataTypes{b,1}) = MergedData.data.(dataTypes{b,1})';
        end
    end
    dp2Fs = 5;
    p2Fs = MergedData.notes.p2Fs;
    trialDuration_Sec = MergedData.notes.trialDuration_Sec;
    expectedLength = trialDuration_Sec*dp2Fs;
    if length(MergedData.data.vesselDiameter) ~= expectedLength
        vesselData = MergedData.data.vesselDiameter;
        sampleMean = mean(vesselData(1:5));
        rsVesselData = resample((vesselData - sampleMean),dp2Fs,p2Fs);
        MergedData.data.vesselDiameter = rsVesselData + sampleMean;
    end
    MergedData.notes.dp2Fs = dp2Fs;
    disp(['Checking data shape for MergedData file ' num2str(a) ' of ' num2str(size(mergedDataFiles,1)) '...']); disp(' ')
    save(mergedDataFile,'MergedData')
end
