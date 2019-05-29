function FigThree_SlowOscReview2019(ComparisonData)
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

%%
animalIDs = fields(ComparisonData);
x = 1;
y = 1;
for a = 1:length(animalIDs)
    animalID = animalIDs{a,1};
    for b = 1:length(ComparisonData.(animalID).WhiskVessel_Coherence.C)
        try
            coherenceData1(x,:) = ComparisonData.(animalID).WhiskVessel_Coherence.C{b,1};
%             shuffledCoherenceData1(x,:) = ComparisonData.(animalID).WhiskVessel_Coherence.shuffC{b,1};
            vID = join([string(animalID) string(ComparisonData.(animalID).WhiskVessel_Coherence.vesselIDs{b,1})]);
            f1 = ComparisonData.(animalID).WhiskVessel_Coherence.f{1,1};
            vIDs1{x,1} = strrep(vID, ' ', '');
            x = x + 1;
        catch
            coherenceData2(y,:) = ComparisonData.(animalID).WhiskVessel_Coherence.C{b,1};
%             shuffledCoherenceData2(y,:) = ComparisonData.(animalID).WhiskVessel_Coherence.shuffC{b,1};
            vID = join([string(animalID) string(ComparisonData.(animalID).WhiskVessel_Coherence.vesselIDs{b,1})]);
            f2 = ComparisonData.(animalID).WhiskVessel_Coherence.f{1,1};
            vIDs2{y,1} = strrep(vID, ' ', '');
            y = y + 1;
        end
    end
end

%% Adjust for differences in trial duration
f1_f2_logical = ismember(f2, f1);
for c = 1:size(coherenceData2, 1)
    coherenceData = coherenceData2(c,:);
%     shuffledCoherenceData = shuffledCoherenceData2(c,:);
    logicalCoherenceData = coherenceData(f1_f2_logical);
%     logicalShuffledCoherenceData = shuffledCoherenceData(f1_f2_logical);
    coherenceData1(x,:) = logicalCoherenceData;
%     shuffledCoherenceData1(x,:) = logicalShuffledCoherenceData;
    vIDs1{x,1} = vIDs2{c,1};
    x = x + 1;
end

%% Averages
coherenceMean = mean(coherenceData1, 1);
coherenceSTD = std(coherenceData1, 1, 1);
% shuffledCoherenceMean = mean(shuffledCoherenceData1, 1);
% shuffledCoherenceSTD = std(shuffledCoherenceData1, 1, 1);

%%
figure;
plot(f1, coherenceMean, 'k', 'LineWidth', 2)
hold on
plot(f1, coherenceMean + coherenceSTD, 'Color', colors('ash grey'))
plot(f1, coherenceMean - coherenceSTD, 'Color', colors('ash grey'))
% plot(f1, shuffledCoherenceMean, 'm')
% plot(f1, shuffledCoherenceMean + shuffledCoherenceSTD)
% plot(f1, shuffledCoherenceMean - shuffledCoherenceSTD)
title('Mean coherence Abs(whiskAccel) vs. vessel diameter')
xlabel('Frequency (Hz)')
ylabel('Coherence')
legend('Original data')
% legend('Original data', 'Shuffled data')
xlim([0.05 0.5])
pause(1)

end