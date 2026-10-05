function [allresulttab] = my_Resultstable(hyperparam, SetupNo, baseResults, solresults, ensembleResults, ensolresults, diversityResults, Strategyselected)
% Creates the results table based on the individual (and ensemble) results
%
% Placeholders:
% m - No. FS methods
% g - No. FS output types
% h - No. shares of features
% a - No. aggregation methods
% c - No. classifiers

if nargin < 7
    diversityResults = []; % no diversity measured
end
if nargin < 8
    Strategyselected = hyperparam.Strategyselected;
end

isEnsemble = ~strcmp(Strategyselected, 'Individual Feature Selection');

nomethods = size(hyperparam.FSselected,2);
if isEnsemble
    nagg = size(hyperparam.ensembleaggmethod,2);
else
    nagg = 0;
end

%% Pre-processing
varnames = {'Name','SubSetup','AvgTestErr','StdTestErr','AvgNoFeat','StdNoFeat'};
vartypes = {'string','string','double','double','double','double'};

nrows = size(hyperparam.method,2) * size(hyperparam.fixednumfeatures,2) * ...
        size(hyperparam.rankingOutput,2) * (nomethods + 1 + nagg); % +1 for average line
resulttab = table('Size',[nrows, numel(varnames)],'VariableTypes',vartypes,'VariableNames',varnames);

%% Construct results table
n = 1; % COUNTER
for c = 1 : size(hyperparam.method,2) % Classifiers
    for h = 1 : size(hyperparam.fixednumfeatures,2) % Shares / Number of Features
        for g = 1 : size(hyperparam.rankingOutput,2) % FS Output Types

            subsetupname = convertCharsToStrings(join(horzcat(hyperparam.rankingOutput{g},'-', ...
                hyperparam.shareinfo(h),'-', hyperparam.method(c))));

            % Results for INDIVIDUAL methods
            for m = 1 : nomethods
                resulttab(n,:) = table(convertCharsToStrings(hyperparam.FSselected(m)), subsetupname, ...
                    mean(baseResults.indresults(:, m, g, h, c)), ...
                    std(baseResults.indresults(:, m, g, h, c)), ...
                    mean(baseResults.sizeresults(:, m, g, h, c)), ...
                    std(baseResults.sizeresults(:, m, g, h, c)), ...
                    'VariableNames', varnames);
                n = n + 1;
            end % individual FS methods [m]

            % Entry line for the AVERAGE over the individual methods
            allerr  = baseResults.indresults(:, :, g, h, c);  allerr  = allerr(:);
            allsize = baseResults.sizeresults(:, :, g, h, c); allsize = allsize(:);
            resulttab(n,:) = table("Average Indiv. FS", subsetupname, ...
                mean(allerr), std(allerr), mean(allsize), std(allsize), ...
                'VariableNames', varnames);
            n = n + 1;

            % Results for ENSEMBLE methods
            for a = 1 : nagg
                resulttab(n,:) = table(convertCharsToStrings(join(horzcat('Ensemble [', ...
                    strjoin(hyperparam.FSselected,'-'),'] (',hyperparam.ensembleaggmethod{a},')'))), ...
                    subsetupname, ...
                    mean(ensembleResults.enindresults(:, g, h, a, c)), ...
                    std(ensembleResults.enindresults(:, g, h, a, c)), ...
                    mean(ensembleResults.ensizeresults(:, g, h, a)), ...
                    std(ensembleResults.ensizeresults(:, g, h, a)), ...
                    'VariableNames', varnames);
                n = n + 1;
            end % Ensemble aggregation methods [a]

        end % FS Output Types [g]
    end % Shares / Number of Features [h]
end % Classifiers [c]

%% Save results
allresulttab = struct();
allresulttab(SetupNo).Resulttable = resulttab;
allresulttab(SetupNo).Subsets = solresults;
allresulttab(SetupNo).Evaluation = baseResults.indresults; % individual performance e.g., error
allresulttab(SetupNo).Sizes = baseResults.sizeresults;
allresulttab(SetupNo).Diversity = diversityResults;

if isEnsemble
    allresulttab(SetupNo).EFSSubsets = ensolresults;
    allresulttab(SetupNo).EFSEvaluation = ensembleResults.enindresults;
    allresulttab(SetupNo).EFSSizes = ensembleResults.ensizeresults;
end

end