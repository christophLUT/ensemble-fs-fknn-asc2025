function [hyperparam] = my_hyperparamCreation(NoSetups, setupidx, Nofeatures, hyperparam)
% Based on specifications provided in the setup(s), add information to the struct
% containing the hyperparameters for feature selection / ensemble feature
% selection.

% 1. Ensemble (or Individual) Strategy
hyperparam.Strategyselected = NoSetups{setupidx}{1}; % Strategy (e.g., 'Individual Feature Selection', 'Function Perturbation [Ensemble]', 'Data Perturbation [Ensemble]')

% 2. Individual Feature Selection Methods selected
hyperparam.FSselected = NoSetups{setupidx}{2}; % FS Methods
hyperparam.nomethods = size(hyperparam.FSselected,2);

% 3. Feature Selection Outputs [Individual]
hyperparam.rankingOutput = NoSetups{setupidx}{3}; % FS Output Type (e.g., 'Subset', 'Ranking', etc)

% 4: Share of Features OR Number
if min(cell2mat(NoSetups{setupidx}{4})) <= 1 % Shares
    hyperparam.fixednumfeatures = max(round(floor(cell2mat(NoSetups{setupidx}{4})*Nofeatures),1),1); % SHARE of Features -> transformed into number (for specific data set)
else % Number of features (integers)
    hyperparam.fixednumfeatures = cell2mat(NoSetups{setupidx}{4}); % NUMBER (integer) of Features
end
hyperparam.ensembleaggfeatnumberorshare = hyperparam.fixednumfeatures; % Set to be the same
hyperparam.shareinfo = cell2mat(NoSetups{setupidx}{4}); % ONLY for resulttable later on
hyperparam.featuresdata = Nofeatures; % No of features in the data set

% 5: Classifier(s) for Evaluation of Feature Selection
hyperparam.method = string(NoSetups{setupidx}{5}); % (e.g., 'KNN', 'FKNN')

% 6: Ensemble Bootstrap [Ensemble - Data Perturbation]
hyperparam.ensemblebootstrapshare = cell2mat(NoSetups{setupidx}{6}); % Share of training observations in bootstrap [0, 1]

% 7. Ensemble Aggregation [Ensemble]
hyperparam.ensembleaggmethod = NoSetups{setupidx}{7}; % Ensemble Aggregation 

% 8. Ensemble (Sub-)Aggregation (not for all aggregation methods required) [Ensemble]
hyperparam.subaggmethod = NoSetups{setupidx}{8}; % Additional Specification for ensemble aggregation

end