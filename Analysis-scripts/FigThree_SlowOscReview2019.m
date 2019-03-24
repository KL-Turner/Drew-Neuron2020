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
for a = 1:length(animalIDs)
    animalID = animalIDs{a,1};
    for b = 1:length(ComparisonData.(animalID).WhiskVessel_Coherence.C)
        coherenceData(x,:) = ComparisonData.(animalID).WhiskVessel_Coherence.C{b,1};
        x = x + 1;
    end 
end

f = ComparisonData.(animalID).WhiskVessel_Coherence.f{1,1};
coherenceMean = mean(coherenceData, 1);
coherenceSTD = std(coherenceData, 1, 1);

%%
figure;
plot(f, coherenceMean, 'k')
hold on
plot(f, coherenceMean + coherenceSTD)
plot(f, coherenceMean - coherenceSTD)
title('Mean coherence Abs(whiskAccel) vs. vessel diameter')
xlabel('Frequency (Hz)')
ylabel('Coherence')
xlim([0 0.5])
pause(1)

end