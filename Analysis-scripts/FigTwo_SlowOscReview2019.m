function FigTwo_SlowOscReview2019(ComparisonData)
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
    animalID = animalIDs{a};
    for b = 1:length(ComparisonData.(animalID).WhiskVessel_XCorr.XC_means)
        XCorrData(x, :) = ComparisonData.(animalID).WhiskVessel_XCorr.XC_means{b,1};
        x = x + 1;
    end 
end
lags = ComparisonData.(animalID).WhiskVessel_XCorr.lags;
xcorrMean = mean(XCorrData, 1);
xcorrSTD = std(XCorrData,1,1);

%%
figure;
plot(lags, xcorrMean, 'k', 'LineWidth', 2)
hold on
plot(lags, xcorrMean + xcorrSTD, 'Color', colors_SlowOscReview2019('ash grey'))
plot(lags, xcorrMean - xcorrSTD, 'Color', colors_SlowOscReview2019('ash grey'))
title('Mean XCorr Abs(whiskAccel) vs. vessel diameter')
ylabel('Correlation')
xlabel('Lags (sec)')
pause(1)

end