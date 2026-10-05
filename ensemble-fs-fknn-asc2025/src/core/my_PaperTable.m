function T = my_PaperTable(Welchtab, classifier, datasetname, rankingOutput, shares)
% Build a paper-style table (one data set, one classifier) from Welchtab.
%
%   classifier    : "FKNN" or "MLPMFKNN"
%   datasetname   : optional, added as first column (e.g. "Sonar")
%   rankingOutput : optional, default 'Ranking'
%   shares        : optional, e.g. [0.001 0.01 0.1 0.25 0.5 0.8]

if nargin < 3, datasetname = ""; end
if nargin < 4 || isempty(rankingOutput), rankingOutput = 'Ranking'; end

%% Parse SubSetup strings of the form "<output> - <share> - <classifier>"
sub = string(Welchtab.SubSetup);
cls = strings(height(Welchtab),1);
shr = nan(height(Welchtab),1);
for i = 1:height(Welchtab)
    tk = split(strtrim(sub(i)));
    cls(i) = tk(end);          % classifier is the last token
    shr(i) = str2double(tk(end-2));  % share is the token before the last "-"
end
keep = strcmp(cls, classifier) & startsWith(sub, rankingOutput);
if ~any(keep), error('No rows for classifier "%s".', classifier); end

if nargin < 5 || isempty(shares)
    shares = unique(shr(keep))';
    shares = shares(shares < 1);   % share 1 is the "No FS" benchmark, not a column
end

%% Row labels and how to find them in Welchtab.Name
rownames = ["No FS"; "Average all FS"; "Ensemble - intersection"; ...
            "Ensemble - average"; "Ensemble - union"];
tags     = [""; "Average Indiv. FS"; "(intersection)"; "(average)"; "(union)"];

C = strings(numel(rownames), numel(shares));
for j = 1:numel(shares)
    rows = find(keep & shr == shares(j));
    if isempty(rows), error('No rows for share %g.', shares(j)); end

    % No FS: benchmark values (identical in every row of this block)
    C(1,j) = fmtcell(Welchtab.BM_AvgTestErr(rows(1)), Welchtab.BM_StdTestErr(rows(1)), "");

    nm = string(Welchtab.Name(rows));
    for r = 2:numel(rownames)
        if r == 2
            idx = rows(strcmp(nm, tags(r)));
        else
            idx = rows(contains(nm, tags(r)));
        end
        if isempty(idx)
            C(r,j) = "-";   % e.g. aggregation method not part of the setup
            continue;
        end
        idx = idx(1);
        % Stars: *** = 0.1 %, ** = 1 %, * = 5 %
        if     Welchtab.("0.1%")(idx), st = "***";
        elseif Welchtab.("1%")(idx),   st = "**";
        elseif Welchtab.("5%")(idx),   st = "*";
        else,                          st = "";
        end
        C(r,j) = fmtcell(Welchtab.AvgTestErr(idx), Welchtab.StdTestErr(idx), st);
    end
end

%% Assemble output table
T = table(rownames, 'VariableNames', {'Method'});
for j = 1:numel(shares)
    T.(sprintf('S%d', j)) = C(:,j);
end
varnames = ["Method", compose("%g %% Features", round(shares*100, 4))];

if datasetname ~= ""
    T = [table(repmat(string(datasetname), numel(rownames), 1), ...
         'VariableNames', {'Dataset'}), T];
    varnames = ["Dataset", varnames];
end
T.Properties.VariableNames = varnames;
end

%% ---- helper: "16.1 ± 6.2***" with errors in percent, 1 decimal ----
function s = fmtcell(err, sd, stars)
s = string(num2str(round(err*100, 1))) + " ± " + ...
    string(num2str(round(sd*100, 1))) + stars;
end