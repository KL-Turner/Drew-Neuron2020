
function Fig7_Accel_Neuron2020(ComparisonData)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Generates K.L. Turner's portion of the data presented in Figure 7 of Drew, Meteo et al. Neuron 2020.
%________________________________________________________________________________________________________________________

% Load the RestingBaselines structure from this animal
cd('T72')
baselineDirectory = dir('*_RestingBaselines.mat');
baselineDataFile = {baselineDirectory.name}';
baselineDataFile = char(baselineDataFile);
load(baselineDataFile,'-mat')

% Load specific file and pull relevant file information for normalization and figure labels
indFile = 'T72_A1_190317_19_21_24_022_MergedData.mat';
load(indFile,'-mat');
[animalID,fileDate,~,vesselID,~] = GetFileInfo2_Neuron2020(indFile);
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

%% Extract data from each animal for the cross-correlation averages
animalIDs = fields(ComparisonData);
x = 1;
for a = 1:length(animalIDs)
    animalID = animalIDs{a};
    for b = 1:length(ComparisonData.(animalID).XCorr.angle)
        angleXC(x,:) = ComparisonData.(animalID).XCorr.angle{b,1}; %#ok<*AGROW,*NASGU>
        velocityXC(x,:) = ComparisonData.(animalID).XCorr.velocity{b,1};
        accelXC(x,:) = ComparisonData.(animalID).XCorr.accel{b,1};
        movementXC(x,:) = ComparisonData.(animalID).XCorr.movement{b,1};
        x = x + 1;
    end 
end
angleXC_Mean = mean(angleXC,1);
angleXC_StErr = (std(angleXC,1,1))/sqrt(size(angleXC,1));
velocityXC_Mean = mean(velocityXC,1);
velocityXC_StErr = std(velocityXC,1,1)/sqrt(size(velocityXC,1));
accelXC_Mean = mean(accelXC,1);
accelXC_StErr = std(accelXC,1,1)/sqrt(size(accelXC,1));
movementXC_Mean = mean(movementXC,1);
movementXC_StErr = std(movementXC,1,1)/sqrt(size(movementXC,1));
lags = ComparisonData.(animalID).XCorr.lags;

%% Extract data from each animal for the coherence averages
x = 1;
y = 1;
for a = 1:length(animalIDs)
    animalID = animalIDs{a,1};
    for b = 1:length(ComparisonData.(animalID).Coherence.angleC)
        try
            % C data from each parameter
            angleCoherenceData1(x,:) = ComparisonData.(animalID).Coherence.angleC{b,1};
            velocityCoherenceData1(x,:) = ComparisonData.(animalID).Coherence.velocityC{b,1};
            accelCoherenceData1(x,:) = ComparisonData.(animalID).Coherence.accelC{b,1};
            movementCoherenceData1(x,:) = ComparisonData.(animalID).Coherence.movementC{b,1};
            % f and confidence interval, which are indentical for each parameter
            f1 = ComparisonData.(animalID).Coherence.f{1,1};
            confC1{x,1} = ComparisonData.(animalID).Coherence.confC{b,1};
            % animal and vessel ID information
            vID = join([string(animalID) string(ComparisonData.(animalID).Coherence.vesselIDs{b,1})]);
            vIDs1{x,1} = strrep(vID,' ','');
            x = x + 1;
        catch
            % C data from each parameter
            angleCoherenceData2(y,:) = ComparisonData.(animalID).Coherence.angleC{b,1};
            velocityCoherenceData2(y,:) = ComparisonData.(animalID).Coherence.velocityC{b,1};
            accelCoherenceData2(y,:) = ComparisonData.(animalID).Coherence.accelC{b,1};
            movementCoherenceData2(y,:) = ComparisonData.(animalID).Coherence.movementC{b,1};
            % f and confidence interval, which are indentical for each parameter
            f2 = ComparisonData.(animalID).Coherence.f{1,1};
            confC2{y,1} = ComparisonData.(animalID).Coherence.confC{b,1};
            % animal and vessel ID information
            vID = join([string(animalID) string(ComparisonData.(animalID).Coherence.vesselIDs{b,1})]);
            vIDs2{y,1} = strrep(vID,' ','');
            y = y + 1;
        end
    end
end

% Adjust for differences in trial duration
f1_f2_logical = ismember(f2,f1);
for c = 1:size(angleCoherenceData2,1)
    angleCoherenceData = angleCoherenceData2(c,:);
    velocityCoherenceData = velocityCoherenceData2(c,:);
    accelCoherenceData = accelCoherenceData2(c,:);
    movementCoherenceData = movementCoherenceData2(c,:);
    logicalAngleCoherenceData = angleCoherenceData(f1_f2_logical);
    logicalVelocityCoherenceData = velocityCoherenceData(f1_f2_logical);
    logicalAccelCoherenceData = accelCoherenceData(f1_f2_logical);
    logicalMovementCoherenceData = movementCoherenceData(f1_f2_logical);
    angleCoherenceData1(x,:) = logicalAngleCoherenceData;
    velocityCoherenceData1(x,:) = logicalVelocityCoherenceData;
    accelCoherenceData1(x,:) = logicalAccelCoherenceData;
    movementCoherenceData1(x,:) = logicalMovementCoherenceData;
    vIDs1{x,1} = vIDs2{c,1};
    confC1{x,1} = confC2{c,1};
    x = x + 1;
end
angleCoherenceMean = mean(angleCoherenceData1,1);
angleCoherenceStErr = std(angleCoherenceData1,1,1)/sqrt(size(angleCoherenceData1,1));
velocityCoherenceMean = mean(velocityCoherenceData1,1);
velocityCoherenceStErr = std(velocityCoherenceData1,1,1)/sqrt(size(velocityCoherenceData1,1));
accelCoherenceMean = mean(accelCoherenceData1,1);
accelCoherenceStErr = std(accelCoherenceData1,1,1)/sqrt(size(accelCoherenceData1,1));
movementCoherenceMean = mean(movementCoherenceData1,1);
movementCoherenceStErr = std(movementCoherenceData1,1,1)/sqrt(size(movementCoherenceData1,1));
confInterval = max(cell2mat(confC1));
confInterval_Y = ones(length(f1),1)*confInterval;

%% Generate summary figure
figure;
% Force sensor
ax1 = subplot(4,4,1:4);
plot((1:length(filteredWhiskerAcceleration))/MergedData.notes.dsFs,filteredWhiskerAcceleration,'color',colors_Neuron2020('sapphire'),'LineWidth',1)
ylabel('Whisker Angle (deg)')
xlim([0 MergedData.notes.trialDuration_Sec])
set(gca,'box','off')
set(gca,'XTickLabel',[]);
% Whisker angle
ax2 = subplot(4,4,5:8);
plot((1:length(filtForceSensor))/MergedData.notes.dsFs,filtForceSensor,'color',colors_Neuron2020('north texas green'),'LineWidth',1)
ylabel('Piezo sensor (V)')
xlim([0 MergedData.notes.trialDuration_Sec])
set(gca,'box','off')
set(gca,'XTickLabel',[]);
% vessel diameter
ax3 = subplot(4,4,9:12);
plot((1:length(filtVesselDiameter))/MergedData.notes.dp2Fs,detrend(filtVesselDiameter,'constant'),'color','k','LineWidth',1)
xlabel('Time (s)')
ylabel('\DeltaD/D (%)')
xlim([0 MergedData.notes.trialDuration_Sec])
set(gca,'box','off')
linkaxes([ax1,ax2,ax3],'x')
% Whisker acceleration vs. vessel diameter coherence
ax4 = subplot(4,4,13);
plot(f1,accelCoherenceMean,'color',colors_Neuron2020('sapphire'),'LineWidth',2)
hold on
plot(f1,accelCoherenceMean + accelCoherenceStErr,'color',colors_Neuron2020('sapphire'),'LineWidth',1)
plot(f1,accelCoherenceMean - accelCoherenceStErr,'color',colors_Neuron2020('sapphire'),'LineWidth',1)
conf = plot(f1,confInterval_Y,'--','color','k','LineWidth',1);
xlabel('Frequency (Hz)')
ylabel({'Coherence';'|Whisker acceleration| vs. \DeltaD/D'})
xlim([0.05,0.5])
ylim([0,0.75])
set(gca,'box','off')
% Whisker acceleration vs. vessel diameter XC
ax5 = subplot(4,4,14);
plot(lags,accelXC_Mean,'color',colors_Neuron2020('sapphire'),'LineWidth',2)
hold on
plot(lags,accelXC_Mean + accelXC_StErr,'color',colors_Neuron2020('sapphire'),'LineWidth',1)
plot(lags,accelXC_Mean - accelXC_StErr,'color',colors_Neuron2020('sapphire'),'LineWidth',1)
xlabel('Lags (s)')
ylabel({'Corr. Coefficient';'|Whisker acceleration| vs. \DeltaD/D'})
xlim([-25,25])
ylim([-0.1,0.75])
set(gca,'box','off')
% Movement vs. vessel diameter coherence
ax6 = subplot(4,4,15);
plot(f1,movementCoherenceMean,'color',colors_Neuron2020('north texas green'),'LineWidth',2)
hold on
plot(f1,movementCoherenceMean + movementCoherenceStErr,'color',colors_Neuron2020('north texas green'),'LineWidth',1)
plot(f1,movementCoherenceMean - movementCoherenceStErr,'color',colors_Neuron2020('north texas green'),'LineWidth',1)
conf = plot(f1,confInterval_Y,'--','Color','k','LineWidth',1);
xlabel('Frequency (Hz)')
ylabel({'Coherence';'|Movement| vs. \DeltaD/D'})
xlim([0.05,0.5])
ylim([0,0.75])
set(gca,'box','off')
% Movement vs. vessel diameter XC
ax7 = subplot(4,4,16);
plot(lags,movementXC_Mean,'color',colors_Neuron2020('north texas green'),'LineWidth',2)
hold on
plot(lags,movementXC_Mean + movementXC_StErr,'color',colors_Neuron2020('north texas green'),'LineWidth',1)
plot(lags,movementXC_Mean - movementXC_StErr,'color',colors_Neuron2020('north texas green'),'LineWidth',1)
xlabel('Lags (s)')
ylabel({'Corr. Coefficient';'|Movement| vs. \DeltaD/D'})
xlim([-25,25])
ylim([-0.1,0.75])
set(gca,'box','off')
pause(1)
cd ..

end
