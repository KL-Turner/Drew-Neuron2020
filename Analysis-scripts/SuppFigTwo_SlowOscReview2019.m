function SuppFigTwo_SlowOscReview2019(ComparisonData)
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
    for b = 1:length(ComparisonData.(animalID).WhiskVessel_XCorr.XC_means)
        XCorrData(x, :) = ComparisonData.(animalID).WhiskVessel_XCorr.XC_means{b,1};
        vID = join([string(animalID) string(ComparisonData.(animalID).WhiskVessel_XCorr.vesselIDs{b,1})]);
        lags = ComparisonData.(animalID).WhiskVessel_XCorr.lags;
        vIDs{x,1} = strrep(vID, ' ', '');
        x = x + 1;
    end
end

%%
figure;
for c = 1:size(XCorrData, 1)
    vID = char(vIDs{c,1});
    animalName = vID(1:3);
    switch animalName
        case 'T72'
            animalColor = colors('candy apple red');
        case 'T73'
            animalColor = colors('deep carrot orange');
        case 'T74'
            animalColor = colors('vegas gold');
        case 'T75'
            animalColor = colors('jungle green');
        case 'T76'
            animalColor = colors('sapphire');
        case 'T80'
            animalColor = colors('otter brown');
        case 'T81'
            animalColor = colors('royal purple');
        case 'T82'
            animalColor = colors('flamingo pink');
        case 'T83'
            animalColor = colors('smoky black');
    end
    plot(lags, XCorrData(c,:), 'LineWidth', 1.5, 'Color', animalColor);
    hold on
end
title('Ind XCorr Abs(whiskAccel) vs. vessel diameter')
ylabel('Correlation')
xlabel('Lags (sec)')
legend(vIDs)
pause(1)

end