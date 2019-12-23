function TempCohXCorrFig_SlowOscReview2019(ComparisonData)
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

for a = 1:size(angleXC)
    [~,angleI(a,1)] = max(angleXC(a,:));
    angleL(a,1) = lags(angleI(a,1));
end
disp(['Angle Mean lag time: ' num2str(round(mean(angleL),2)) ' seconds +/- StD ' num2str(round(std(angleL),2)) ' seconds ']); disp(' ')

for a = 1:size(velocityXC)
    [~,velocityI(a,1)] = max(velocityXC(a,:));
    velocityL(a,1) = lags(velocityI(a,1));
end
disp(['Velocity Mean lag time: ' num2str(round(mean(velocityL),2)) ' seconds +/- StD ' num2str(round(std(velocityL),2)) ' seconds ']); disp(' ')

for a = 1:size(accelXC)
    [~,accelI(a,1)] = max(accelXC(a,:));
    accelL(a,1) = lags(accelI(a,1));
end
disp(['Acceleration Mean lag time: ' num2str(round(mean(accelL),2)) ' seconds +/- StD ' num2str(round(std(accelL),2)) ' seconds ']); disp(' ')

for a = 1:size(movementXC)
    [~,movementI(a,1)] = max(movementXC(a,:));
    movementL(a,1) = lags(movementI(a,1));
end
disp(['Movement Mean lag time: ' num2str(round(mean(movementL),2)) ' seconds +/- StD ' num2str(round(std(movementL),2)) ' seconds ']); disp(' ')

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
% Whisker angle vs. vessel diameter XC
subplot(2,4,1)
plot(lags,angleXC_Mean,'k','LineWidth',2)
hold on
plot(lags,angleXC_Mean + angleXC_StErr,'Color',colors_SlowOscReview2019('ash grey'))
plot(lags,angleXC_Mean - angleXC_StErr,'Color',colors_SlowOscReview2019('ash grey'))
xlabel('Lags (s)')
ylabel({'Corr. Coefficient';'WhiskAngle vs. \DeltaD/D'})
xlim([-50,50])
ylim([0,0.75])
set(gca,'box','off')
axis square
% Whisker velocity vs. vessel diameter XC
subplot(2,4,2)
plot(lags,velocityXC_Mean,'k','LineWidth',2)
hold on
plot(lags,velocityXC_Mean + velocityXC_StErr,'Color',colors_SlowOscReview2019('ash grey'))
plot(lags,velocityXC_Mean - velocityXC_StErr,'Color',colors_SlowOscReview2019('ash grey'))
xlabel('Lags (s)')
ylabel({'Corr. Coefficient';'|WhiskVel| vs. \DeltaD/D'})
xlim([-50,50])
ylim([0,0.75])
set(gca,'box','off')
axis square
% Whisker acceleration vs. vessel diameter XC
subplot(2,4,3)
plot(lags,accelXC_Mean,'k','LineWidth',2)
hold on
plot(lags,accelXC_Mean + accelXC_StErr,'Color',colors_SlowOscReview2019('ash grey'))
plot(lags,accelXC_Mean - accelXC_StErr,'Color',colors_SlowOscReview2019('ash grey'))
xlabel('Lags (s)')
ylabel({'Corr. Coefficient';'|WhiskAccel| vs. \DeltaD/D'})
xlim([-50,50])
ylim([0,0.75])
set(gca,'box','off')
axis square
% Movement vs. vessel diameter XC
subplot(2,4,4)
plot(lags,movementXC_Mean,'k','LineWidth',2)
hold on
plot(lags,movementXC_Mean + movementXC_StErr,'Color',colors_SlowOscReview2019('ash grey'))
plot(lags,movementXC_Mean - movementXC_StErr,'Color',colors_SlowOscReview2019('ash grey'))
xlabel('Lags (s)')
ylabel({'Corr. Coefficient';'|Movement| vs. \DeltaD/D'})
xlim([-50,50])
ylim([0,0.75])
set(gca,'box','off')
axis square
% Whisker angle vs. vessel diameter coherence
subplot(2,4,5)
plot(f1,angleCoherenceMean,'k','LineWidth',2)
hold on
plot(f1,angleCoherenceMean + angleCoherenceStErr,'Color',colors_SlowOscReview2019('ash grey'))
plot(f1,angleCoherenceMean - angleCoherenceStErr,'Color',colors_SlowOscReview2019('ash grey'))
conf = plot(f1,confInterval_Y,'--','Color',colors_SlowOscReview2019('vegas gold'),'LineWidth',2);
xlabel('Frequency (Hz)')
ylabel({'Coherence';'WhiskAngle vs. \DeltaD/D'})
legend(conf,'95% conf inteval')
xlim([0.05,0.5])
ylim([0,0.75])
set(gca,'box','off')
axis square
% Whisker velocity vs. vessel diameter coherence
subplot(2,4,6)
plot(f1,velocityCoherenceMean,'k','LineWidth',2)
hold on
plot(f1,velocityCoherenceMean + velocityCoherenceStErr,'Color',colors_SlowOscReview2019('ash grey'))
plot(f1,velocityCoherenceMean - velocityCoherenceStErr,'Color',colors_SlowOscReview2019('ash grey'))
conf = plot(f1,confInterval_Y,'--','Color',colors_SlowOscReview2019('vegas gold'),'LineWidth',2);
xlabel('Frequency (Hz)')
ylabel({'Coherence';'|WhiskVel| vs. \DeltaD/D'})
xlim([0.05,0.5])
ylim([0,0.75])
set(gca,'box','off')
axis square
% Whisker acceleration vs. vessel diameter coherence
subplot(2,4,7)
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
axis square
% Movement vs. vessel diameter coherence
subplot(2,4,8)
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
axis square

end
