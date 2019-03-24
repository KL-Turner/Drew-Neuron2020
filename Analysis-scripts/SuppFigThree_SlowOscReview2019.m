function SuppFigThree_SlowOscReview2019(ComparisonData)
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
        vID = join([string(animalID) string(ComparisonData.(animalID).WhiskVessel_Coherence.vesselIDs{b,1})]);
        vIDs{x,1} = strrep(vID, ' ', '');
        x = x + 1;
    end 
end

f = ComparisonData.(animalID).WhiskVessel_Coherence.f{1,1};

%%
figure;
for c = 1:size(coherenceData,1)
    plot(f, coherenceData(c,:));
    hold on
end
title('Ind coherence Abs(whiskAccel) vs. vessel diameter')
xlabel('Frequency (Hz)')
ylabel('Coherence')
legend(vIDs)
xlim([0 0.5])
pause(1)

end