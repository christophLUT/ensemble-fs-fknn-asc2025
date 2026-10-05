function [allresulttab, hyperparam] = applyEnsembleFS_efficient(x,y, NoSetups, hyperparam)
% Implementation for Feature Selection and Ensemble Feature Selection
% Christoph Lohrmann, Reykjavik University, Iceland

tic
%% Conduct Feature Selection / Ensemble Feature Selection
for b = 1 : size(NoSetups,2)

%% 0. Get setup for current "b" run
hyperparam = my_hyperparamCreation(NoSetups, b, size(x,2), hyperparam);

%% Information to the user
disp(horzcat('Selected Strategy: ',hyperparam.Strategyselected));
disp(horzcat('Selected Methods: ',strjoin(unique(hyperparam.FSselected(:)),', '))); % only unique (important for the case of an ensemble)

%% 1. Conducting (external) data split and determine indices for data sets
[CV_all_indices] = my_CVindices(y, hyperparam); % struct

%% 2. Applying all INDIVIDUAL methods   
solresults = my_baseFeatureSelection(x, y, CV_all_indices.train, hyperparam);

% Display 
disp(horzcat('###### Step 2 - Application of INDIVIDUAL Methods completed! [Duration: ', num2str(round(toc/60,1)),' Min] ######'))
                

%% 3. Evaluate Feature Selection on TEST data for all INDIVIDUAL methods
baseResults = my_baseEvaluation(x, y, CV_all_indices, solresults, hyperparam);

% Display 
disp(horzcat('###### Step 3 - Evaluation of INDIVIDUAL Methods completed! [Duration: ', num2str(round(toc/60,1)),' Min] ######'))

%% 4. Aggregation of Subsets / Rankings / Scores
if  (strcmp(hyperparam.Strategyselected, 'Data Perturbation [Ensemble]') | strcmp(hyperparam.Strategyselected, 'Function Perturbation [Ensemble]'))
    
    %% 4.1. Aggregation of individual subsets / rankings / scores of base learners
    ensolresults = my_ensembleAggregation(solresults, hyperparam);

    %% 4.2. Evaluation of aggregated subset / ranking / scores from the ensemble
    ensembleResults = my_ensembleEvaluation(x, y, CV_all_indices, ensolresults, hyperparam);
end

% Display 
disp(horzcat('###### Step 4 - Evaluation of ENSEMBLE(S) completed! [Duration: ', num2str(round(toc/60,1)),' Min] ######'))


%% 5. Construct Results table
allresulttab = my_Resultstable(hyperparam, b, baseResults, solresults, ensembleResults, ensolresults);

% Display 
disp(horzcat('###### Step 5 - Creation of Result Table completed! [Duration: ', num2str(round(toc/60,1)),' Min] ######'))

end

end


