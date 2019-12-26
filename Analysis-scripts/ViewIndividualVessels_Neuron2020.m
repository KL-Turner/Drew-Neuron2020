function[] = ViewIndividualVessels_Neuron2020()
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Generates K.L. Turner's portion of the data presented in Figure 7 of Drew, Meteo et al. Neuron 2020.
%________________________________________________________________________________________________________________________

% Load the RestingBaselines structure from this animal
baselineDirectory = dir('*_RestingBaselines.mat');
baselineDataFile = {baselineDirectory.name}';
baselineDataFile = char(baselineDataFile);
load(baselineDataFile,'-mat')

% Load specific file and pull relevant file information for normalization and figure labels
indFile = uigetfile('*_MergedData.mat');
load(indFile,'-mat');
[~,fileDate,~,vesselID,~] = GetFileInfo2_Neuron2020(indFile);
strDay = ConvertDate_Neuron2020(fileDate);

%% BLOCK PURPOSE: Filter the whisker angle and identify the solenoid timing and location.
% Setup butterworth filter coefficients for a 10 Hz lowpass based on the sampling rate (30 Hz).
dsFs = 30;            % Hz 
whiskerCamFs = 150;   % Hz
analogFs = 20000;     % Hz
[z1,p1,k1] = butter(2,20/(whiskerCamFs/2),'low');
[sos1,g1] = zp2sos(z1,p1,k1);
[z2,p2,k2] = butter(2,20/(analogFs/2),'low');
[sos2,g2] = zp2sos(z2,p2,k2);
[B,A] = butter(3,10/(MergedData.notes.dsFs/2),'low');
filteredWhiskerAngle = filtfilt(B,A,resample(filtfilt(sos1,g1,abs(MergedData.data.rawWhiskerAngle - 135)),dsFs,whiskerCamFs));
filteredWhiskerAcceleration = filtfilt(B,A,resample(filtfilt(sos1,g1,diff(abs(MergedData.data.rawWhiskerAngle - 135),2)),dsFs,whiskerCamFs));
filtForceSensor = filtfilt(B,A,resample(filtfilt(sos2,g2,MergedData.data.rawForceSensorM),dsFs,analogFs));
binWhiskers = MergedData.data.binWhiskerAngle;
binForce = MergedData.data.binForceSensorM;

%% CBV data - normalize and then lowpass filer
% Setup butterworth filter coefficients for a 2 Hz lowpass based on the sampling rate.
[D,C] = butter(3,2/(MergedData.notes.dp2Fs/2),'low');
vesselDiameter = MergedData.data.vesselDiameter;
normVesselDiameter = (vesselDiameter - RestingBaselines.(vesselID).(strDay).vesselDiameter.baseLine)./(RestingBaselines.(vesselID).(strDay).vesselDiameter.baseLine);
filtVesselDiameter = filtfilt(D,C,normVesselDiameter)*100;

%% Generate summary figure
figure;
% Force sensor
ax1 = subplot(3,1,1);
plot((1:length(filteredWhiskerAngle))/MergedData.notes.dsFs,filteredWhiskerAngle,'color',colors_Neuron2020('sapphire'),'LineWidth',1)
ylabel('Whisker Angle (deg)')
xlim([0 MergedData.notes.trialDuration_Sec])
set(gca,'box','off')
set(gca,'XTickLabel',[]);
% Whisker angle
ax2 = subplot(3,1,2);
plot((1:length(filtForceSensor))/MergedData.notes.dsFs,filtForceSensor,'color',colors_Neuron2020('north texas green'),'LineWidth',1)
ylabel('Piezo sensor (V)')
xlim([0 MergedData.notes.trialDuration_Sec])
set(gca,'box','off')
set(gca,'XTickLabel',[]);
% vessel diameter
ax3 = subplot(3,1,3);
plot((1:length(filtVesselDiameter))/MergedData.notes.dp2Fs,detrend(filtVesselDiameter,'constant'),'color','k','LineWidth',1)
xlabel('Time (s)')
ylabel('\DeltaD/D (%)')
xlim([0 MergedData.notes.trialDuration_Sec])
set(gca,'box','off')
linkaxes([ax1,ax2,ax3],'x')

end