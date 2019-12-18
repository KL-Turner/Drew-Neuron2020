function Fig7_SlowOscReview2019(ComparisonData)
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
%   Last Revised: March 22nd, 2019
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
        [animalID,fileDate,fileID,vesselID,~] = GetFileInfo2_SlowOscReview2019(indFile);
        strDay = ConvertDate_SlowOscReview2019(fileDate);
        
        %% BLOCK PURPOSE: Filter the whisker angle and identify the solenoid timing and location.
        % Setup butterworth filter coefficients for a 10 Hz lowpass based on the sampling rate (30 Hz).
        [B,A] = butter(3,10/(MergedData.notes.dsFs/2),'low');
        filteredWhiskerAngle = filtfilt(B,A,MergedData.data.whiskerAngle);
        filtForceSensor = filtfilt(B,A,MergedData.data.forceSensorM);
        binWhiskers = MergedData.data.binWhiskerAngle;
        binForce = MergedData.data.binForceSensorM;
        
        %% CBV data - normalize and then lowpass filer
        % Setup butterworth filter coefficients for a 1 Hz lowpass based on the sampling rate (20 Hz).
        [D,C] = butter(3,1/(MergedData.notes.p2Fs/2),'low');
        vesselDiameter = MergedData.data.vesselDiameter;
        normVesselDiameter = (vesselDiameter - RestingBaselines.(vesselID).(strDay).vesselDiameter.baseLine)./(RestingBaselines.(vesselID).(strDay).vesselDiameter.baseLine);
        filtVesselDiameter = (filtfilt(D,C,normVesselDiameter))*100;
        
        %% Yvals for behavior Indices
        whisking_YVals = 1.10*max(detrend(filtVesselDiameter,'constant'))*ones(size(binWhiskers));
        force_YVals = 1.20*max(detrend(filtVesselDiameter,'constant'))*ones(size(binForce)); 

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

%%
figure;
% Force sensor
ax1 = subplot(5,2,1:2);
plot((1:length(filtForceSensor))/MergedData.notes.dsFs,filtForceSensor,'color',colors_SlowOscReview2019('sapphire'),'LineWidth',2)
ylabel('Force (V)')
xlim([0 MergedData.notes.trialDuration_Sec])
set(gca,'box','off')
% Whisker angle
ax2 = subplot(5,2,3:4);
plot((1:length(filteredWhiskerAngle))/MergedData.notes.dsFs,-filteredWhiskerAngle,'color',colors_SlowOscReview2019('carrot orange'),'LineWidth',2)
ylabel('Angle (deg)')
xlim([0 MergedData.notes.trialDuration_Sec])
set(gca,'box','off')
% vessel diameter
ax3 = subplot(5,2,5:6);
plot((1:length(filtVesselDiameter))/MergedData.notes.p2Fs,detrend(filtVesselDiameter,'constant'),'color',colors_SlowOscReview2019('dark candy apple red'),'LineWidth',2)
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
scatter((1:length(binForce))/MergedData.notes.dsFs,forceInds,'.','MarkerEdgeColor',colors_SlowOscReview2019('sapphire'));
scatter((1:length(binWhiskers))/MergedData.notes.dsFs,whiskInds,'.','MarkerEdgeColor',colors_SlowOscReview2019('carrot orange'));
xlabel('Time (s)')
ylabel('\DeltaD/D (%)')
legend('Vessel diameter','Binarized movement events','binarized whisking events')
xlim([0 MergedData.notes.trialDuration_Sec])
set(gca,'box','off')
linkaxes([ax1,ax2,ax3],'x')
% Whisker acceleration vs. vessel diameter XC
ax4 = subplot(5,2,7);
plot(lags,accelXC_Mean,'k','LineWidth',2)
hold on
plot(lags,accelXC_Mean + accelXC_StErr,'Color',colors_SlowOscReview2019('ash grey'))
plot(lags,accelXC_Mean - accelXC_StErr,'Color',colors_SlowOscReview2019('ash grey'))
xlabel('Lags (s)')
ylabel({'Corr. Coefficient';'|WhiskAccel| vs. \DeltaD/D'})
xlim([-25,25])
ylim([-0.1,0.75])
set(gca,'box','off')
% Movement vs. vessel diameter XC
ax5 = subplot(5,2,8);
plot(lags,movementXC_Mean,'k','LineWidth',2)
hold on
plot(lags,movementXC_Mean + movementXC_StErr,'Color',colors_SlowOscReview2019('ash grey'))
plot(lags,movementXC_Mean - movementXC_StErr,'Color',colors_SlowOscReview2019('ash grey'))
xlabel('Lags (s)')
ylabel({'Corr. Coefficient';'|Movement| vs. \DeltaD/D'})
xlim([-25,25])
ylim([-0.1,0.75])
set(gca,'box','off')
% Whisker acceleration vs. vessel diameter coherence
ax6 = subplot(5,2,9);
plot(f1,accelCoherenceMean,'k','LineWidth',2)
hold on
plot(f1,accelCoherenceMean + accelCoherenceStErr,'Color',colors_SlowOscReview2019('ash grey'))
plot(f1,accelCoherenceMean - accelCoherenceStErr,'Color',colors_SlowOscReview2019('ash grey'))
conf = plot(f1,confInterval_Y,'--','Color',colors_SlowOscReview2019('vegas gold'),'LineWidth',2);
xlabel('Frequency (Hz)')
ylabel({'Coherence';'|WhiskAccel| vs. \DeltaD/D'})
xlim([0.05,0.5])
ylim([0,0.75])
set(gca,'box','off')
% Movement vs. vessel diameter coherence
ax7 = subplot(5,2,10);
plot(f1,movementCoherenceMean,'k','LineWidth',2)
hold on
plot(f1,movementCoherenceMean + movementCoherenceStErr,'Color',colors_SlowOscReview2019('ash grey'))
plot(f1,movementCoherenceMean - movementCoherenceStErr,'Color',colors_SlowOscReview2019('ash grey'))
conf = plot(f1,confInterval_Y,'--','Color',colors_SlowOscReview2019('vegas gold'),'LineWidth',2);
xlabel('Frequency (Hz)')
ylabel({'Coherence';'|Movement| vs. \DeltaD/D'})
xlim([0.05,0.5])
ylim([0,0.75])
set(gca,'box','off')

end
