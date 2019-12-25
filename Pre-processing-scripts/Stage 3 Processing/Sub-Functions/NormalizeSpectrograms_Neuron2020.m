function [SpecData] = NormalizeSpectrograms_Neuron2020(specDataFiles,RestingBaselines)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Normalizes each spectrogram by the resting baseline for that day.
%________________________________________________________________________________________________________________________

for a = 1:size(specDataFiles,1)
    disp(['Normalizing spectrogram file ' num2str(a) ' of ' num2str(size(specDataFiles,1)) '...']); disp(' ')
    load(specDataFiles(a,:),'-mat');
    [~,fileDate,~,~,~] = GetFileInfo2_Neuron2020(specDataFiles(a,:));
    strDay = ConvertDate_Neuron2020(fileDate);
    % baseline per day for one second and five second spectrograms
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
    save(specDataFiles(a,:),'SpecData')
end

end
