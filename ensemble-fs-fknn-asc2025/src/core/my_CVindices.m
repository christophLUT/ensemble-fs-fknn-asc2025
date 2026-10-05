function [CV_all_indices] = my_CVindices(y, hyperparam)
% Determine the indices for the training data (external) and test data for
% a given number of k-folds (stratified random sampling) with potential
% additional boostrapping (with replacement). Indices are positions (integers), not binary 
%
% INPUTS:
%   y:          Class labels
%   hyperparam: Struct containing information on the number of folds
%               (hyperparam.foldsexternalCV) and number of runs (hyperparam.runs) and, 
%               optionally, the bootstrapshare (hyperparam.ensemblebootstrapshare)


% Pre-processing of DATA SAMPLES for each run and fold and bootstrap / ensemble member
CV_train_indices = cell(hyperparam.foldsexternalCV, hyperparam.runs);
CV_test_indices = cell(hyperparam.foldsexternalCV, hyperparam.runs);

% Depending on the strategy applied, generate indices for cross-validation procedure
switch hyperparam.Strategyselected
    case 'Individual Feature Selection'
        % External Data Split
        for i = 1 : hyperparam.runs

            % Data Division (in each run)
            excrossval = cvpartition(y,'KFold',hyperparam.foldsexternalCV,'Stratify',true); % cvpartition(n,'Leaveout')

            % Determine indices for k-fold CV
            for ex = 1 : hyperparam.foldsexternalCV
                % Take the unchanged training indices
                CV_train_indices{ex, i} = find(excrossval.training(ex));
                CV_test_indices{ex, i} = find(excrossval.test(ex));
            end
        end % hyperparam.runs [i]

    case 'Function Perturbation [Ensemble]'
        % External Data Split
        for i = 1 : hyperparam.runs % WRONG POSITIONING !!! overwirtes CV indices!!!

            % Data Division (in each run)
            excrossval = cvpartition(y,'KFold',hyperparam.foldsexternalCV,'Stratify',true); % cvpartition(n,'Leaveout')

            % Determine indices for k-fold CV
            for ex = 1 : hyperparam.foldsexternalCV
                % Take the unchanged training indices
                CV_train_indices{ex, i} = find(excrossval.training(ex));
                CV_test_indices{ex, i} = find(excrossval.test(ex));
            end
        end % hyperparam.runs [i]

end % switch Strategyselected

% Create struct containing indices for training and test data sets
CV_all_indices.train = CV_train_indices;
CV_all_indices.test = CV_test_indices;
end