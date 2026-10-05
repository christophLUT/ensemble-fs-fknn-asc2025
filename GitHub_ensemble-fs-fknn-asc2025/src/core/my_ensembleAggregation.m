function [ensolresults] = my_ensembleAggregation(solresults, hyperparam)
% Aggregate individual subsets / rankings / scores from base learners. Type
% of otput to the aggregated specified in hyperparam.rankingOutput (multiple possible).

% Pre-process results vector for the ensemble [independent on number of classifiers]
ensubsetresult = cell(hyperparam.foldsexternalCV * hyperparam.runs, size(hyperparam.rankingOutput,2), size(hyperparam.fixednumfeatures,2), size(hyperparam.ensembleaggmethod,2)); % ensemble subsets: all folds (for all runs) x type of output x number of featres x aggregation methods used
enranksubresults = cell(hyperparam.foldsexternalCV * hyperparam.runs, size(hyperparam.rankingOutput,2), size(hyperparam.fixednumfeatures,2), size(hyperparam.ensembleaggmethod,2)); % ensemble ranking 
enscoreresultsall = cell(hyperparam.foldsexternalCV * hyperparam.runs, size(hyperparam.rankingOutput,2), size(hyperparam.fixednumfeatures,2), size(hyperparam.ensembleaggmethod,2)); % ensemble scores (ALL): all folds (for all runs) x type of output x number of featres x aggregation methods used
ensortedscoresubsetresults = cell(hyperparam.foldsexternalCV * hyperparam.runs, size(hyperparam.rankingOutput,2), size(hyperparam.fixednumfeatures,2), size(hyperparam.ensembleaggmethod,2)); % ensemble SORTED Scores (only for SUBSET)


for i = 1 : hyperparam.runs % iterations / runs
    for ex = 1 : hyperparam.foldsexternalCV % folds 

        % Aggregation of Subsets / Rankings / Scores
            for g = 1 : size(hyperparam.rankingOutput,2) % Different desired Output Types (Not No. of ensemble members / ensemble size) [(i, ex, m), g]
                for h = 1 : size(hyperparam.fixednumfeatures,2) % [(i, ex, m), g, h]
                    
                    % Subset data to be aggregated
                    switch hyperparam.rankingOutput{g}
                        case 'Ranking'
                            individsolution = solresults.ranksubresults((ex +(i-1) * hyperparam.foldsexternalCV), :); % for all fixednmberfeatures(h), the same ranking as starting point (no 3rd dim)

                        case 'Score'
                            individsolution = solresults.scoreresults((ex +(i-1) * hyperparam.foldsexternalCV), :); % for all fixednmberfeatures(h), the same scores as starting point (no 3rd dim)

                        case 'Subset'
                            individsolution = solresults.subsetresult((ex +(i-1) * hyperparam.foldsexternalCV), :, h); % 3rd dimension that includes the final subset
                            
                        case 'Subset & Score'
                            individsolution = solresults.scoreresults((ex +(i-1) * hyperparam.foldsexternalCV), :); % for all fixednmberfeatures(h), the same scores as starting point (no 3rd dim)
                    end

                   
                    % Aggregation for the type of output provided
                    for a = 1 : size(hyperparam.ensembleaggmethod,2) % for each aggregation method [(i, ex, m), g, h, a]
                        % Determine Aggregated Subset / Ranking / Scores
                        [enaggregated, ~] = AggFunction(individsolution, hyperparam.ensembleaggmethod{a}, ...
                                hyperparam.ensembleaggfeatnumberorshare(h), hyperparam.featuresdata, hyperparam.subaggmethod{a},hyperparam.rankingOutput{g},'standardize'); % (1) Subsets (cell), (2) runs/folds, (3) aggregation method e.g. "union", (4) number/share of most frequent subsets (5) number of features in the entire data set
    
                        % Save resulting aggregated ensemble subsets / rankings / scores
                        ensubsetresult{(ex + (i-1) * hyperparam.foldsexternalCV), g, h, a} = enaggregated.aggsubset; % Subset
                        enranksubresults{(ex + (i-1) * hyperparam.foldsexternalCV), g, h, a} = enaggregated.aggrankingall; % Ranking (all)
                        enscoreresultsall{(ex + (i-1) * hyperparam.foldsexternalCV), g, h, a} = enaggregated.aggscoreall ; % Scores (all)
                        ensortedscoresubsetresults{(ex + (i-1) * hyperparam.foldsexternalCV), g, h, a} = enaggregated.aggsortedscoresubset; % SORTED Scores (only for SUBSET)

                    end % hyperparam.ensembleaggmethod (a)
                end % hyperparam.fixednumfeatures (h)
            end % hyperparam.rankingOutput (g)
    end
end

% Create a struct with all results
ensolresults.subsetresult = ensubsetresult;
ensolresults.ranksubresults = enranksubresults;
ensolresults.scoreresults = enscoreresultsall;
ensolresults.sortedscoresubset= ensortedscoresubsetresults; % sorted and subset
end