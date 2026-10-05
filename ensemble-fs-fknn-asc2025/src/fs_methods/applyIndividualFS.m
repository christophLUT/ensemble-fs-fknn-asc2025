function [subset, ranking, scores, fitness, fitnessDev] = applyIndividualFS(FSselected, dataTrain, classTrain, hyperparam)

% FSselected: Method name (cell)
% dataTrain: data without class label
% classTrain: vector of class labels
% hyperparam: contains all hyperparameters
% OUTPUT:
%
% COLUMN vectors

% ENSURE that 'subset', 'ranking' and 'scores' are COLUMN vectors as outputs

subset = [];
ranking = [];
scores = [];
fitness = -1; % fixed here as not needed for filter methods
fitnessDev = [1 -1]; % fixed here as not needed for filter methods

%% Find Features / Variables that have constant values 
% (Note: this may occur due to the data split even when the featres in the overall data set have few values that are not the same)

idxconstant = find(var(dataTrain)==0); % required for Fisher Score, MI, Pearson, Strife, SU

%% Apply Feature Selection Methods
switch FSselected{:}

        % ########## No Feature Selection ##########
        case 'NoFS'
            % No Feature Selection - Benchmark model
            subset = 1:size(dataTrain,2); % All features
            subset = subset(:);
        
        % ########## Traditional FS Methods ##########
        case 'Chisquared'
            % Chi-squared test
            [ranking,scores] = fscchi2(dataTrain, classTrain); % ranked ordered, scores not 
            ranking = ranking(:);
            scores = scores(:);
            scores(scores == Inf) = max(scores(scores < Inf)) * 10; % Correct possible Inf scores to be "just" 10-times larger than largest non Inf score

        case 'Fisher'
            % Fisher Score
            [scores, ranking] = fisherFS(dataTrain, classTrain); % ranked ordered, scores not

            scores(idxconstant) = 0; % Set scores of NaN (e.g., due to constant values for variable) to 0 [FIX required for methods that result in NaN scores for variables with constant values and, ths, rank them first]
            
            [~, ranking] = sort(scores,'descend');

         case 'MI'
            % Mutual Information
            scores = zeros(size(dataTrain,2),1);
            for z = 1:size(dataTrain,2)
                scores(z) = muteinf_MI(dataTrain(:,z), classTrain);
            end
            scores(idxconstant) = 0; % Set scores of NaN (e.g., due to constant values for variable) to 0 [FIX required for methods that result in NaN scores for variables with constant values and, ths, rank them first]
            [~, ranking] = sort(scores,'descend'); % ranked ordered, scores not


        case 'MRMR'
            % Minimum Redundandy Maximum Relevance (MRMR)
            [ranking, scores] = fscmrmr(dataTrain, classTrain); % (inbuilt Matlab Function); % ranked ordered, scores not
            ranking = ranking(:);
            scores = scores(:);

        case 'Pearson'
            corrmat = abs(corrcoef([dataTrain, classTrain])); 
            scores = corrmat(1:size(corrmat,1)-1,size(corrmat,2));
            scores(idxconstant) = 0; % Set scores of NaN (e.g., due to constant values for variable) to 0 [FIX required for methods that result in NaN scores for variables with constant values and, ths, rank them first]
            [~, ranking] = sort(scores,'descend'); % ranked ordered, scores not

        case 'ReliefF'
            % ReliefF with 70 Near Hits/Misses and Sigma = 20
            [ranking, scores] = relieff(dataTrain, classTrain,70,'sigma',20,'method','classification'); % ReliefF(70, sigma 20); % ranked ordered, scores not
            % [ranking, ~] = relieff(dataTrain, classTrain,10,'method','classification'); % ReliefF
            ranking = ranking(:);
            scores = scores(:);

        case 'Strife'
            % Strife (Possibility Theory)
            [~, scores] = FSstrifePoss([dataTrain, classTrain],1:size(dataTrain,2),size(dataTrain,2)+1,1); % uses p = 1; % ranked ordered, scores not
            scores(idxconstant) = 0; % Set scores of NaN (e.g., due to constant values for variable) to 0 [FIX required for methods that result in NaN scores for variables with constant values and, ths, rank them first]
            [~, ranking] = sort(scores,'descend'); % ranked ordered, scores not

       
        case 'SU'
            % Symmetrical Uncertainty
            scores = zeros(size(dataTrain,2),1); % Symmetrical Uncertainty (standardized Mutual Information)
            for z = 1:size(dataTrain,2)
                scores(z) = muteinf(dataTrain(:,z), classTrain); % calculates SU directly
            end
            scores(idxconstant) = 0; % Set scores of NaN (e.g., due to constant values for variable) to 0 [FIX required for methods that result in NaN scores for variables with constant values and, ths, rank them first]
            [~, ranking]=sort(scores,'descend');

        otherwise
            disp('other value')
    end

end
