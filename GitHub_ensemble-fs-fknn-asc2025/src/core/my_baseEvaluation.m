function [baseResults] = my_baseEvaluation(x, y, CV_all_indices, solresults, hyperparam)
% Evaluate individual feature selection / ranking / scoring results
%
% INPUTS:
%  solresults: struct ontaining 3 fields: subsetresult, ranksubresults,
%              scoreresults, each containing for one or multiple methods (i.e.,
%              columns) the results for multiple folds & runs (rows)


% Pre-processing individual performance and subset size
indresults = zeros(hyperparam.foldsexternalCV * hyperparam.runs, hyperparam.nomethods, size(hyperparam.rankingOutput,2), size(hyperparam.fixednumfeatures,2), size(hyperparam.method,2)); % pre-process results of methods
sizeresults = zeros(hyperparam.foldsexternalCV * hyperparam.runs, hyperparam.nomethods , size(hyperparam.rankingOutput,2), size(hyperparam.fixednumfeatures,2), size(hyperparam.method,2)); % pre-process results of methods

% Evaluate the performance and number of features
for i = 1 : hyperparam.runs % iterations / runs
    for ex = 1 : hyperparam.foldsexternalCV % folds 

        % Evaluate Feature Selection on TEST data for all INDIVIDUAL methods
        for m = 1 : hyperparam.nomethods
            for g = 1 : size(hyperparam.rankingOutput,2) % No of different FS output types [(i, ex, m), g]
                for h = 1 : size(hyperparam.fixednumfeatures,2) % [(i, ex, m), g, h]
                    
                    switch hyperparam.rankingOutput{g}
                        case 'Ranking'
                            % Determine the Solution by subsetting the rankings
                            solution = solresults.ranksubresults{(ex +(i-1) * hyperparam.foldsexternalCV), m}(1:hyperparam.fixednumfeatures(h));

                            % Calculate test set errors
                            [testerror, nofeatures] = EvalFunction(x(CV_all_indices.train{ex,i},solution), y(CV_all_indices.train{ex,i}), x(CV_all_indices.test{ex,i},solution), y(CV_all_indices.test{ex,i}), hyperparam);

                        case 'Score'
                            % Determine the Solution by subsetting the rankings (reflecting the sorted scores)
                            solution = solresults.ranksubresults{(ex +(i-1) * hyperparam.foldsexternalCV), m}(1:hyperparam.fixednumfeatures(h));

                            % Calculate test set errors
                            [testerror, nofeatures] = EvalFunction(x(CV_all_indices.train{ex,i},solution), y(CV_all_indices.train{ex,i}), x(CV_all_indices.test{ex,i},solution), y(CV_all_indices.test{ex,i}), hyperparam);
                            
                        case 'Subset'
                            % Determine the Solution - already subsets, so no subsetting required
                            solution = solresults.subsetresult{(ex +(i-1) * hyperparam.foldsexternalCV), m, h}; % no subsetting via fixednmfeatures required

                            % Calculate test set errors
                            [testerror, nofeatures] = EvalFunction(x(CV_all_indices.train{ex,i},solution), y(CV_all_indices.train{ex,i}), x(CV_all_indices.test{ex,i},solution), y(CV_all_indices.test{ex,i}), hyperparam);
                            
                        case 'Subset & Score'
                            % Determine the Solution
                            solution = solresults.ranksubresults{(ex +(i-1) * hyperparam.foldsexternalCV), m}(1:hyperparam.fixednumfeatures(h));
                            tempscores = solresults.scoreresults{(ex +(i-1) * hyperparam.foldsexternalCV), m}; % for calculating the testerror (individual)
                            tempscores(tempscores < 0) = 0; % Setting negative scores to 0

                            % Calculate test set errors [SPECIAL - scores as weights]
                            [testerror, nofeatures] = EvalFunction(x(CV_all_indices.train{ex,i},solution).*(sqrt(tempscores(solution))'), y(CV_all_indices.train{ex,i}), ...
                                x(CV_all_indices.test{ex,i},solution).*(sqrt(tempscores(solution))'), y(CV_all_indices.test{ex,i}), hyperparam);
                    end
                    
                    % Record test error, number of features retained, and solutions
                    indresults((ex +(i-1) * hyperparam.foldsexternalCV), m, g, h,:) = testerror;
     
                    % Record number of features retained, and solutions
                    sizeresults((ex +(i-1) * hyperparam.foldsexternalCV), m, g, h, :) = nofeatures;
                    
                end % number / share of features (h)
            end % rankingoutputs (g)
        end % methods (m)
    end % external folds [ex]
end % runs [i]

% Create a struct with all results
baseResults.indresults = indresults; % Performance e.g., test error
baseResults.sizeresults = sizeresults; % Subset Sizes
end