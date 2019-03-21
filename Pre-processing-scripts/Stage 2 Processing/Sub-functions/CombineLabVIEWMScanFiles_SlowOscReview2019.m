function CombineLabVIEWMScanFiles_SlowOscReview2019(labviewDataFiles, mscanDataFiles)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
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

for f = 1:size(labviewDataFiles, 1)
    disp(['Combining the data from LabVIEW and MScan file(s) number ' num2str(f) ' of ' num2str(size(labviewDataFiles, 1)) '...']); disp(' ');
    labviewDataFile = labviewDataFiles(f, :);
    mscanDataFile = mscanDataFiles(f, :);
    load(labviewDataFile);
    load(mscanDataFile);
    
    [animalID, ~, ~, fileID] = GetFileInfo_SlowOscReview2019(labviewDataFile);
    vesselID = MScanData.notes.vesselID;
    
    % Pull the notes and data from LabVIEW
    MergedData.notes.LabVIEW = LabVIEWData.notes;
    MergedData.data.whiskerAngle = LabVIEWData.data.dsWhiskerAngle_trim;
    MergedData.data.binWhiskerAngle = LabVIEWData.data.binWhiskerAngle_trim;
    MergedData.data.forceSensorL = LabVIEWData.data.dsForceSensor_trim;
    MergedData.data.binForceSensorL = LabVIEWData.data.binForceSensorL_trim;
    
    % Pull the notes and data from MScan
    MergedData.notes.MScan = MScanData.notes;
    MergedData.data.rawNeuralData = MScanData.data.rawNeuralData_trim;
    MergedData.data.muaPower = MScanData.data.muaPower_trim;
    MergedData.data.gammaPower = MScanData.data.gammaPower_trim;
    MergedData.data.betaPower = MScanData.data.betaPower_trim;
    MergedData.data.alphaPower = MScanData.data.alphaPower_trim;
    MergedData.data.thetaPower = MScanData.data.thetaPower_trim;
    MergedData.data.deltaPower = MScanData.data.deltaPower_trim;
    MergedData.data.forceSensorM = MScanData.data.dsForceSensorM_trim;
    MergedData.data.binForceSensorM = MScanData.data.binForceSensorM_trim;
    MergedData.data.vesselDiameter = MScanData.data.vesselDiameter_trim;
    MergedData.data.EMG = MScanData.data.filtEMG2;
    
    % Most useful notes to be referenced in future analysis
    MergedData.notes.trialDuration_Sec = LabVIEWData.notes.trialDuration_Seconds_trim;
    MergedData.notes.p2Fs = MScanData.notes.frameRate;
    MergedData.notes.dsFs = LabVIEWData.notes.downSampledFs;
    
    save([animalID '_' vesselID '_' fileID '_MergedData'], 'MergedData')
end

end
