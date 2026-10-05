function [enaggregated, subsetfreq] = AggFunction(solresults, aggmethod, shareornumber, nofeatures, subaggmethod, fstype, scorestandard)
% Aggregation of Feature Substets according to a specific method e.g., union or intersection
% Christoph Lohrmann, LUT University, Finland
%
% INPUT
%   solresults: cell input containing in each cell the feature subset for
%               one method or run
%   aggmethod: aggregation method used to conduct the aggregation e.g.
%              union (of the subsets)
%   shareornumber: share or number of features most frequently being contained in subsets that 
%                  should be included in the aggregation
%   nofeatures: number of features in the entire data set
%   // subaggmethod: determines how shareornumber input is implemented 'mostfrequent','graph'
%
% OUTPUT
%   enaggregated: the aggregated subsets/rankings/scores
%              ("solresults") via the aggregation method ("aggmethod")
%   subsetfreq: frequency of occurence of the features contained in the
%               aggregated feature subset

scalefactor = 100; % for scaling scores not to [0, 1] but [0, scalefactor] below

% Pre-processing
aggscoreall = []; % pre-process as empty (otherwise overwritten later] - UNSORTED, ALL
aggrankingall = [];  % pre-process as empty - will be based on aggregated scores, if available

aggsubset = []; % pre-process as empty - SUBSET only
aggsortedscoresubset = []; % pre-process as empty - will be based on aggregated scores, if available - SORTED. SUBSET only
subsetfreq = NaN; % default (only set by intersection / union)

% Determine / assign number of features for subsets
if shareornumber<1
    retainfeat = max(ceil(shareornumber * nofeatures),1);
else
    retainfeat = shareornumber;
end
        
for i = 1 : size(solresults,1)

switch fstype

    %% RANKING AGGREGATION
    case 'Ranking'
            tempidxrank = zeros(size(solresults{1,1},1),size(solresults,2)); % For each position its rank
            for k = 1 : size(solresults,2)
                allfeat = 1 : size(solresults{1,1},1);
                allfeat(solresults{i,k}) = allfeat;
                tempidxrank(:,k) = allfeat;
            end
            temprank = [solresults{i,:}]; % the highest ranked features (first idx of highest ranked, second idx of second highest ranked, etc)
            
        % Average Rank    
        if strcmp(aggmethod,'average')
            [~, sortrank] = sort(mean(tempidxrank,2),'ascend');
            aggsubset = sortrank(1:retainfeat);
            subsetfreq = NaN;       

        elseif strcmp(aggmethod,"intersection") % intersection of features in subsets (directly created here from rankings) for aggregated subset 
            % Convert Ranking to Subset
            retainsubsets = temprank(1:retainfeat,:);
            uniquefeat = unique(retainsubsets);
            freq = sum(histc(retainsubsets,uniquefeat),2);

            % In case intersection is NOT empty
            if size(uniquefeat(freq==size(solresults,2)),1)>0 % 2 for the size
                aggsubset = uniquefeat(freq==size(solresults,2)); % Features that were selected in each fold
                subsetfreq = freq(freq==size(solresults,2)); % frequency of the features in the aggregated feature subset
            else % In case intersection is empty
                aggsubset = uniquefeat(subsref(find(freq==max(freq)),struct('type','()','subs',{{randi([1 length(find(freq==max(freq)))],1)}}))); % select most frequent individual feature (if multiple, at random)
                subsetfreq = freq(uniquefeat==aggsubset);
            end

        % Union
        elseif strcmp(aggmethod,"union") % union of features in subsets for aggregated subset

            % Convert Ranking to Subset
            retainsubsets = temprank(1:retainfeat,:);
            uniquefeat = unique(retainsubsets);
            freq = sum(histc(retainsubsets,uniquefeat),2);

            aggsubset = uniquefeat; % All features that were selected at least once
            subsetfreq = freq(freq>=1); % frequency of the features in the aggregated feature subset
        end
            
    
    %% SCORE AGGREGATION
    case 'Score'

        scores = [solresults{i,:}];
        scores(scores < 0) = 0; % Setting negative scores to 0
        % Normalize to [0, 1]
        if strcmp(scorestandard, 'standardize') 
            colmin = min(scores);
            colmax = max(scores);

            scores = rescale(scores,"InputMin",colmin,"InputMax",colmax) * scalefactor; % scaled to [0, scalefactor] as differences between [0, 1] may be small

        end

        % Average (standardized) Score
        if strcmp(aggmethod,'average')
            [sortval, sortmean] = sort(mean(scores,2),'descend');
            aggsubset = sortmean(1:retainfeat);
            subsetfreq = NaN; 

            % Determine aggregated scores (SORTED, for SUBSET)
            aggsortedscoresubset = sortval(1:retainfeat);

            % All scores (unsorted, all features)
            aggscoreall = mean(scores,2);

            % Create aggreated ranking based on aggregated score
            aggrankingall = sortmean;

        end

        

    %% SUBSET & Score Aggregation (= SCORE AGGREGATION)
    case 'Subset & Score'

        scores = [solresults{i,:}];
        scores(scores < 0) = 0; % Setting negative scores to 0
        % Normalize to [0, 1]
        if strcmp(scorestandard, 'standardize') 
            colmin = min(scores);
            colmax = max(scores);

            scores = rescale(scores,"InputMin",colmin,"InputMax",colmax)  * scalefactor; % scaled to [0, scalefactor] as differences between [0, 1] may be small;

        end

        % Average Score
        if strcmp(aggmethod,'average')
            [sortval, sortmean] = sort(mean(scores,2),'descend');
            aggsubset = sortmean(1:retainfeat); % SORTED (according to scores)
            subsetfreq = NaN; 

            % Determine aggregated scores (SORTED, for SUBSET)
            aggsortedscoresubset = sortval(1:retainfeat);

            % All scores (unsorted, all features)
            aggscoreall = mean(scores,2);

            % Create aggreated ranking based on aggregated score
            aggrankingall = sortmean;
        end

    %% SUBSET AGGREGATION    
    case 'Subset'

        % Counting all unique appearances of each feature
        uniquefeat = unique([solresults{i,:}]);
        freq = sum(histc([solresults{i,:}],uniquefeat),2);

        if strcmp(aggmethod,"intersection") % intersection of features in subsets for aggregated subset     
            % In case intersection is NOT empty
            if size(uniquefeat(freq==size(solresults,2)),2)>0
                aggsubset = uniquefeat(freq==size(solresults,2)); % Features that were selected in each fold
                subsetfreq = freq(freq==size(solresults,2)); % frequency of the features in the aggregated feature subset
            else % In case intersection is empty
                aggsubset = uniquefeat(subsref(find(freq==max(freq)),struct('type','()','subs',{{randi([1 length(find(freq==max(freq)))],1)}}))); % select most frequent individual feature (if multiple, at random)
                subsetfreq = freq(uniquefeat==aggsubset);
            end
            
        elseif strcmp(aggmethod,"maxfrequent") % features associated with maximum occurence frequency in subsets are included in aggregated subset
            aggsubset = uniquefeat(find(freq==max(freq))); % select most frequent individual feature(s) (individual or subset)
            subsetfreq = max(freq); % frequency of the most frequent feature(s)
        
        elseif strcmp(aggmethod,"union") % union of features in subsets for aggregated subset
            aggsubset = uniquefeat; % All features that were selected at least once
            subsetfreq = freq(freq>=1); % frequency of the features in the aggregated feature subset
    
        end
end % End intersection
end

% Create a struct with all results
enaggregated.aggscoreall = aggscoreall; % ALL scores
enaggregated.aggrankingall = aggrankingall; % ALL rankings
enaggregated.aggsortedscoresubset = aggsortedscoresubset; % Sorted scores (only SUBSET)
enaggregated.aggsubset = aggsubset; % (only SUBSET)

end


