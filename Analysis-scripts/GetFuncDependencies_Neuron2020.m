function [functionList] = GetFuncDependencies_Neuron2020(a,functionName,functionNames,functionList)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Outputs all dependencies of a given function, including subfunction dependencies. It also verifies this by
%            looping through each subfunction and further checking that it doesn't have any dependencies.
%________________________________________________________________________________________________________________________

% Detect OS and set delimeter to correct value. This typically isn't necessary in newer versions of Matlab.
if isunix
    delimiter = '/';
elseif ispc
    delimiter = '\';
else
    disp('Platform not currently supported');
    return
end

% Attempt to use Matlab's codetool feature to detect function dependencies.
try
    [fList,~] = matlab.codetools.requiredFilesAndProducts(functionName);
catch
    % Catch the instance where the filename does not exist or was spelled incorrectly.
    disp(['Matlab function ' functionName ' does not appear to exist or to be included in the current filepath(s)']);
    return
end

% Find the unique functions listed and pull the names out.
uniqueFuncPaths = unique(fList);
allDepFuncNames = cell(size(uniqueFuncPaths,2),1);
allDepFuncPaths = cell(size(uniqueFuncPaths,2),1);
for x = 1:size(uniqueFuncPaths, 2)
    allDepFuncPaths{x,1} = uniqueFuncPaths{1,x};
    funcDelimiters = strfind(allDepFuncPaths{x,1},delimiter);
    allDepFuncNames{x,1} = char(strip(allDepFuncPaths{x,1}(funcDelimiters(end):end),delimiter));
end
functionList.names{a,1} = allDepFuncNames;
functionList.paths{a,1} = allDepFuncPaths;

allFileNames = {};   % Pre-alloc
allFilePaths = {};   % Pre-alloc
% Generate results table if this is the last animal. This value is hard-coded for this specific analysis.
if a == length(functionNames)
    for b = 1:length(functionList.names)
        tableVals{b,1} = sortrows(horzcat(functionList.names{b,1}, functionList.paths{b,1}));
        fileNames{b,1} = tableVals{b,1}(:,1);
        filePaths{b,1} = tableVals{b,1}(:,2);
        fileNames{b,1} = vertcat(functionNames{1,b},{''},fileNames{b,1},{''});
        filePaths{b,1} = vertcat({''},{''},filePaths{b,1},{''});
        allFileNames = vertcat(allFileNames,fileNames{b,1});
        allFilePaths = vertcat(allFilePaths,filePaths{b,1});
    end
    % Table
    T = table(allFileNames,allFilePaths,'VariableNames',{'File_names','File_paths'});
    figure('Name','Function dependencies table','NumberTitle','off')
    u = uitable('Data',T{:,:},'ColumnName',T.Properties.VariableNames,'RowName',T.Properties.RowNames,'Units','Normalized','Position',[0,0,1,1]);
    set(u,'ColumnWidth',{300})
end
pause(1)

end
