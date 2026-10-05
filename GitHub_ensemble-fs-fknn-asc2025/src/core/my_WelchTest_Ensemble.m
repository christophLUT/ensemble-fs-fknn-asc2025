function [Welchtab] = my_WelchTest_Ensemble(allresulttab,  hyperparam)
% Conducting a one-sided Welch's test (unequal variances t-test) focused on
% right tail (a set of performance values being significantly better than a
% second set of performance values)

%% Pre-processing
Welchtab = table('Size', [size(hyperparam.method,2) * size(hyperparam.fixednumfeatures,2) * size(hyperparam.rankingOutput,2) * (length(hyperparam.FSselected) + 1 + size(hyperparam.ensembleaggmethod,2)), 11], 'VariableTypes', ...
    {'string','string','double', 'double','double','double','double', 'double','double', 'double','double'}, 'VariableNames', {'Name', 'SubSetup', 'AvgTestErr', 'BM_AvgTestErr', 'StdTestErr', 'BM_StdTestErr','p-value', '10%', '5%', '1%','0.1%'});

n = 1; % Counter

%% Conducting Welch's test
for c = 1 : size(hyperparam.method,2) % Classifiers
    
    % "No FS" benchmark, which is ranking output with share 1 (all features)
    idxAllFeatures = find(hyperparam.shareinfo == 1, 1);                    % position of share 1
    idxRanking     = find(strcmp(hyperparam.rankingOutput, 'Ranking'), 1);  % position of 'Ranking' output
    if isempty(idxAllFeatures) || isempty(idxRanking)
        error('Benchmark not in setup: needs ''Ranking'' output and share 1.');
    end
    benchmark = allresulttab.Evaluation(:, 1, idxRanking, idxAllFeatures, c);


    for h = 1 : size(hyperparam.fixednumfeatures,2) % Shares / Number of Features
        for g = 1 : size(hyperparam.rankingOutput,2) % FS Output Types

            % Results for INDIVIDUAL methods
            for m = 1 : length(hyperparam.FSselected)

                % Current performance results
                selectedresults = allresulttab.Evaluation(:, m, g, h, c);

               %% Significance test and saving results
               % null hypothesis that the data in vectors x and y comes from independent random samples from normal distributions with equal means
               % The result hrejected is 1 (ONE) if the test REJECTS the null hypothesis at the 5% significance level, and 0 otherwise.

               [hrejected01, pval] = ttest2(benchmark,selectedresults,'Vartype','unequal','Tail','right','Alpha',0.001); % Tests if significantly LOWER [for ERRORS] !!!!!!!!!!
               [hrejected1, ~] = ttest2(benchmark,selectedresults,'Vartype','unequal','Tail','right','Alpha',0.01);
               [hrejected5, ~] = ttest2(benchmark,selectedresults,'Vartype','unequal','Tail','right','Alpha',0.05);
               [hrejected10, ~] = ttest2(benchmark,selectedresults,'Vartype','unequal','Tail','right','Alpha',0.10);
               

                % Add information to table
                Welchtab(n,:) = table(convertCharsToStrings(hyperparam.FSselected(m)), ...
                    convertCharsToStrings(join(horzcat(hyperparam.rankingOutput{g},'-',hyperparam.shareinfo(h),'-', hyperparam.method(c)))), ...
                    mean(selectedresults),...
                    mean(benchmark), ...
                    std(selectedresults), ...
                    std(benchmark), ...
                    round(pval, 5), ...
                    hrejected10, ...
                    hrejected5, ...
                    hrejected1,...
                    hrejected01, ...
                    'VariableNames',{'Name', 'SubSetup', 'AvgTestErr', 'BM_AvgTestErr', 'StdTestErr', 'BM_StdTestErr','p-value', '10%', '5%', '1%','0.1%'});

                n = n + 1; % COUNTER

                % Add Entry line for Average Values of individual methods
                if m == length(hyperparam.FSselected)

                   % Current performance results
                   selectedresults = reshape(allresulttab.Evaluation(:, :, g, h, c), size(allresulttab.Evaluation(:, :, g, h, c),1)* size(allresulttab.Evaluation(:, :, g, h, c),2),1); % ALL Individuals TOGETHER

                   %% Significance test and saving results
                   % null hypothesis that the data in vectors x and y comes from independent random samples from normal distributions with equal means
                   % The result hrejected is 1 (ONE) if the test REJECTS the null hypothesis at the 5% significance level, and 0 otherwise.
    
                   [hrejected01, pval] = ttest2(benchmark,selectedresults,'Vartype','unequal','Tail','right','Alpha',0.001); % Tests if significantly LOWER [for ERRORS] !!!!!!!!!!
                   [hrejected1, ~] = ttest2(benchmark,selectedresults,'Vartype','unequal','Tail','right','Alpha',0.01);
                   [hrejected5, ~] = ttest2(benchmark,selectedresults,'Vartype','unequal','Tail','right','Alpha',0.05);
                   [hrejected10, ~] = ttest2(benchmark,selectedresults,'Vartype','unequal','Tail','right','Alpha',0.10);

                    Welchtab(n,:) = table(convertCharsToStrings("Average Indiv. FS"), ...
                    convertCharsToStrings(join(horzcat(hyperparam.rankingOutput{g},'-',hyperparam.shareinfo(h),'-', hyperparam.method(c)))), ...
                    mean(selectedresults),...
                    mean(benchmark), ...
                    std(selectedresults), ...
                    std(benchmark), ...
                    round(pval, 5), ...
                    hrejected10, ...
                    hrejected5, ...
                    hrejected1,...
                    hrejected01, ...
                    'VariableNames',{'Name', 'SubSetup', 'AvgTestErr', 'BM_AvgTestErr', 'StdTestErr', 'BM_StdTestErr','p-value', '10%', '5%', '1%','0.1%'});

                    n = n + 1; % COUNTER
                end

            end % individual FS methods [m]

            % Results for ENSEMBLE methods
            for a = 1 : size(hyperparam.ensembleaggmethod,2) % Ensemble aggregation methods

                   % Current performance results
                   selectedresults = allresulttab.EFSEvaluation(:, g, h, a, c); % selected Ensemble result

                   %% Significance test and saving results
                   % null hypothesis that the data in vectors x and y comes from independent random samples from normal distributions with equal means
                   % The result hrejected is 1 (ONE) if the test REJECTS the null hypothesis at the 5% significance level, and 0 otherwise.
    
                   [hrejected01, pval] = ttest2(benchmark,selectedresults,'Vartype','unequal','Tail','right','Alpha',0.001); % Tests if significantly LOWER [for ERRORS] !!!!!!!!!!
                   [hrejected1, ~] = ttest2(benchmark,selectedresults,'Vartype','unequal','Tail','right','Alpha',0.01);
                   [hrejected5, ~] = ttest2(benchmark,selectedresults,'Vartype','unequal','Tail','right','Alpha',0.05);
                   [hrejected10, ~] = ttest2(benchmark,selectedresults,'Vartype','unequal','Tail','right','Alpha',0.10);
                
                Welchtab(n,:) = table(convertCharsToStrings(join(horzcat('Ensemble [',strjoin(hyperparam.FSselected,'-'),'] (',hyperparam.ensembleaggmethod{a},')'))), ...
                    convertCharsToStrings(join(horzcat(hyperparam.rankingOutput{g},'-',hyperparam.shareinfo(h),'-', hyperparam.method(c)))), ...
                    mean(selectedresults),...
                    mean(benchmark), ...
                    std(selectedresults), ...
                    std(benchmark), ...
                    round(pval, 5), ...
                    hrejected10, ...
                    hrejected5, ...
                    hrejected1,...
                    hrejected01, ...
                    'VariableNames',{'Name', 'SubSetup', 'AvgTestErr', 'BM_AvgTestErr', 'StdTestErr', 'BM_StdTestErr','p-value', '10%', '5%', '1%','0.1%'}); 

                n = n + 1; % COUNTER

            end % Ensemble aggregation methods [a]

        end % FS Output Types [g]
    end % Shares / Number of Features [h]
end  % Classifiers [c]

end




