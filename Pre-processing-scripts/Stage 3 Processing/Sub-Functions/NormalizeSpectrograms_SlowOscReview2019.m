function [SpecData] = NormalizeSpectrograms_SlowOscReview2019(specDataFiles, RestingBaselines)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% Ph.D. Candidate, Department of Bioengineering
% The Pennsylvania State University
%________________________________________________________________________________________________________________________
%
%   Purpose: //
%________________________________________________________________________________________________________________________
%
%   Inputs: //
%
%   Outputs: //
%________________________________________________________________________________________________________________________

for a = 1:size(specDataFiles,1)
    disp(['Normalizing spectrogram file ' num2str(a) ' of ' num2str(size(specDataFiles,1)) '...']); disp(' ')
    load(specDataFiles(a,:), '-mat');
    [~, fileDate, ~, ~, ~] = GetFileInfo2_SlowOscReview2019(specDataFiles(a,:));
    strDay = ConvertDate_SlowOscReview2019(fileDate);
    baseLine1 = RestingBaselines.Spectrograms.oneSec.(strDay);
    baseLine5 = RestingBaselines.Spectrograms.fiveSec.(strDay);

    S1 = SpecData.oneSec.S;
    S5 = SpecData.fiveSec.S;
    
    holdMatrix1 = baseLine1.*ones(size(S1));
    holdMatrix5 = baseLine5.*ones(size(S5));
    
    normS1 = (S1 - holdMatrix1)./holdMatrix1;
    normS5 = (S5 - holdMatrix5)./holdMatrix5;

    SpecData.oneSec.normS = normS1;
    SpecData.fiveSec.normS = normS5;
    save(specDataFiles(a,:), 'SpecData')
end

end
