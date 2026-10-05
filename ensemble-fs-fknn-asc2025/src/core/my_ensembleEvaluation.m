function [ensembleResults] = my_ensembleEvaluation(x, y, CV_all_indices, ensolresults, hyperparam)
% Determine the performance of the ensemble sbset / ranking / scores on the
% test set and provide the performance and subset sizes.


% Pre-process results vector for the ensemble [independent on number of classifiers]
ensizeresults = zeros(hyperparam.foldsexternalCV * hyperparam.runs, size(hyperparam.rankingOutput,2), size(hyperparam.fixednumfeatures,2), size(hyperparam.ensembleaggmethod,2)); % ensemble size: all folds (for all runs) x type of output x number of featres x aggregation methods used
enindresults = zeros(hyperparam.foldsexternalCV * hyperparam.runs, size(hyperparam.rankingOutput,2), size(hyperparam.fixednumfeatures,2), size(hyperparam.ensembleaggmethod,2), size(hyperparam.method,2)); % ensemble performance: all folds (for all runs) x type of output x number of featres x aggregation methods used
        

for i = 1 : hyperparam.runs % iterations / runs
    for ex = 1 : hyperparam.foldsexternalCV % folds 

        % Evaluation of AGGREGATED Ensemble Subsets / Rankings / Scores on TEST DATA
            for g = 1 : size(hyperparam.rankingOutput,2) % No. Subsetups (Not No. of ensemble members / ensemble size) % --------- [(i, ex, m), g]
                for h = 1 : size(hyperparam.fixednumfeatures,2) % [(i, ex, m), g, h]
                    for a = 1 : size(hyperparam.ensembleaggmethod,2) % for each aggregation method [(i, ex, m), g, h, a]
                                                
                       switch hyperparam.rankingOutput{g}
                            case 'Ranking'
                                [testerror, nofeatures] = EvalFunction(x(CV_all_indices.train{ex,i},ensolresults.subsetresult{(ex + (i-1) * hyperparam.foldsexternalCV), g, h, a}), y(CV_all_indices.train{ex,i}), ...
                                    x(CV_all_indices.test{ex,i},ensolresults.subsetresult{(ex + (i-1) * hyperparam.foldsexternalCV), g, h, a}), y(CV_all_indices.test{ex,i}), hyperparam);

                           case 'Score'
                                [testerror, nofeatures] = EvalFunction(x(CV_all_indices.train{ex,i},ensolresults.subsetresult{(ex + (i-1) * hyperparam.foldsexternalCV), g, h, a}), y(CV_all_indices.train{ex,i}), ...
                                    x(CV_all_indices.test{ex,i},ensolresults.subsetresult{(ex + (i-1) * hyperparam.foldsexternalCV), g, h, a}), y(CV_all_indices.test{ex,i}), hyperparam);
    
                            case 'Subset'
                                [testerror, nofeatures] = EvalFunction(x(CV_all_indices.train{ex,i},ensolresults.subsetresult{(ex + (i-1) * hyperparam.foldsexternalCV), g, h, a}), y(CV_all_indices.train{ex,i}),....
                                    x(CV_all_indices.test{ex,i},ensolresults.subsetresult{(ex + (i-1) * hyperparam.foldsexternalCV), g, h, a}), y(CV_all_indices.test{ex,i}), hyperparam);
                                
                            case 'Subset & Score'
                                % Special Case as AGGREGATED SCORES for WEIGHTING
                                 [testerror, nofeatures] = EvalFunction(x(CV_all_indices.train{ex,i},ensolresults.subsetresult{(ex + (i-1) * hyperparam.foldsexternalCV), g, h, a}).*(sqrt(ensolresults.sortedscoresubset{(ex + (i-1) * hyperparam.foldsexternalCV), g, h, a})'), y(CV_all_indices.train{ex,i}), ...
                                     x(CV_all_indices.test{ex,i}, ensolresults.subsetresult{(ex + (i-1) * hyperparam.foldsexternalCV), g, h, a}).*(sqrt(ensolresults.sortedscoresubset{(ex + (i-1) * hyperparam.foldsexternalCV), g, h, a})'),...
                                     y(CV_all_indices.test{ex,i}), hyperparam);

                        end
                        
                        % Save results (performance and subset size)
                        enindresults((ex + (i-1) * hyperparam.foldsexternalCV), g, h, a, :) = testerror; % for each classifier
                        ensizeresults((ex + (i-1) * hyperparam.foldsexternalCV), g, h, a) = nofeatures(1); % (independent of classifier used --> only first number of features as identical number)

                    end % hyperparam.ensembleaggmethod (a)
                end % hyperparam.fixednumfeatures (h)
            end % hyperparam.rankingOutput (g)
                             
    end % folds (ex)
end % runs (i)

% Create a struct with all results
ensembleResults.enindresults = enindresults; % Performance e.g., test error
ensembleResults.ensizeresults = ensizeresults; % Subset Sizes

end