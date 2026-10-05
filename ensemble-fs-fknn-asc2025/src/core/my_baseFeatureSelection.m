function [solresults] = my_baseFeatureSelection(x, y, CVindices, hyperparam)
% Uses "applyIndividualFS" to run individual feature selection methods (base selectors)

%% Pre-processing of INDIVIDUAL results

subsetresult  = cell(hyperparam.foldsexternalCV * hyperparam.runs, size(hyperparam.FSselected,2), size(hyperparam.fixednumfeatures,2)); % best solution in each fold (in each run)
ranksubresults = cell(hyperparam.foldsexternalCV * hyperparam.runs, size(hyperparam.FSselected,2)); % best solution (ranking) in each fold (in each run)
scoreresults = cell(hyperparam.foldsexternalCV * hyperparam.runs, size(hyperparam.FSselected,2)); % scores in each fold (in each run)

% Generate all individual feature subsets / rankings / scores for all CV folds (ex) and runs (i)
for i = 1 : hyperparam.runs % iterations / runs
    for ex = 1 : hyperparam.foldsexternalCV % folds 
        %% 2.1. Get current (external) training data set
        dataTrain = x(CVindices{ex, i},:); % dataTrainEx
        classTrain = y(CVindices{ex, i}); % classTrainEx

        %% 2.2. Applying all INDIVIDUAL methods to (external) training data sets  
            for m = 1 : size(hyperparam.FSselected,2) % individal methods

                % Apply FS method
                [solution, ranking, scores, ~, ~] = applyIndividualFS(hyperparam.FSselected(m), dataTrain, classTrain, hyperparam);

                % Adjust scores in case of NaN Values for scores
                if any(isnan(scores))
                    scores(isnan(scores)) = 0; % Replace NaN scores with zeros
                end

                % Save results (Subsets / rankings / scores)
                if isempty(solution) %For feature ranking methods
                    for h = 1 : size(hyperparam.fixednumfeatures,2) % share of features
                        subsetresult{(ex +(i-1) * hyperparam.foldsexternalCV), m, h} = ranking(1:hyperparam.fixednumfeatures(h));
                    end
                
                else % filter with subset evaluation (not feature ranking) --> provided non-empty subset itself
                    subsetresult{(ex +(i-1) * hyperparam.foldsexternalCV), m, :} = solution; % POTENTIAL ASSIGNMENT ISSUE ////////////////////////////////////////////// (as third index via "h")
                end

                ranksubresults{(ex +(i-1) * hyperparam.foldsexternalCV), m} = ranking;
                scoreresults{(ex +(i-1) * hyperparam.foldsexternalCV), m} = scores;
        
                % Display 
                disp(horzcat('###### Method ',num2str(m),': ', hyperparam.FSselected{m}, ': ',num2str(i), ' out of ', num2str(hyperparam.runs),' - Fold ', num2str(ex),' out of ',num2str(hyperparam.foldsexternalCV),' [Duration: ', num2str(round(toc/60,1)),' Min] ######'))
                
            end %individual methods [m]
    end % folds [ex]
end % hyperparam.runs [i]

% Create a struct with all results
solresults.subsetresult = subsetresult;
solresults.ranksubresults = ranksubresults;
solresults.scoreresults = scoreresults;
end