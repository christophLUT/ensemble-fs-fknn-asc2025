function [testerror,nofeatures] = EvalFunction(dataTrain, classTrain, dataTest, classTest, hyperparam)
% Training a model ("hyperparam.method") on training data and evaluation based on the test set

% Hyperparameters contained in "hyperparam" input
for i = 1 : size(hyperparam.method,2)
    if strcmp(hyperparam.method(i),'KNN') 
        %% KNN classifier 
        
        % Model Training (SPECIAL since lazy learner)
        mdl = fitcknn(dataTrain,classTrain,'Distance','euclidean','NumNeighbors',hyperparam.methodKNNkval);
    
        
        % Test Error
        testerror(i) = 1 - mean(predict(mdl,dataTest)==classTest);
        
        % Number of Features
        nofeatures(i) = size(dataTest,2);
    
    elseif strcmp(hyperparam.method(i),'FKNN') 
        %% Fuzzy KNN classifier 
        
        % Model Training (SPECIAL since lazy learner) and testerror
        [predicted, ~, ~] = fknn(dataTrain, classTrain, dataTest, classTest, hyperparam.methodKNNkval, 0, true); % train, trainlabel, test, testlabel, No Neighbors, Info, Fuzzy
    
        % Test Error
        testerror(i) = 1 - mean(predicted==classTest);
        
        % Number of Features
        nofeatures(i) = size(dataTest,2);
    
    elseif strcmp(hyperparam.method(i),'MLPMFKNN')
        % Modified Local Means-based Fuzzy KNN Classifier
        [predicted, ~, ~] = mlpm_fknn_updated(dataTrain, classTrain, dataTest, classTest, hyperparam.methodKNNkval, hyperparam.MLPMFKNNp, true);
    
        % Test Error
        testerror(i) = 1 - mean(predicted==classTest);
        
        % Number of Features
        nofeatures(i) = size(dataTest,2);
    
    else
        
    end

end

