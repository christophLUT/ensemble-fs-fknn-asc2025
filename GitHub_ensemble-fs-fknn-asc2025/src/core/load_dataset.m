function [x, y, data, allnames] = load_dataset(dataname, processing)
% Specify name of the data set and whether it should be pre-processed

% March 2025

%% All currently available data sets
allnames = {'Arcene', 'Arrhythmia', 'BreastCancerEW', 'bColonoscopy', 'Colon', 'Colonoscopy', 'CongressEW', 'DLBCL', 'Glioma', 'Hillvalley',...
    'Kidney', 'KrVsKpEW', 'Leukemia1', 'LSVT', 'Lung', 'Lymphoma', 'Prostate', 'Scene', ...
    'Sonar', 'Spambase', 'SpectEW', 'SRBCT', 'WaveformEW', '11_Tumors'};


%% With NO input, return list of data sets that can be loaded
if nargin == 0
    x = [];
    y=[];
    data = [];
    dataname = 'None';
    processing = 0;

    if nargout == 0
        disp(allnames)
    end

elseif nargin == 1

    % If not specified, set processing to 1 as default
    processing = 1;
end

%% Check if desired data set exists
if ismember(dataname, allnames)
elseif nargin == 0
    % show nothing
else
    error('Selected data set names not among data sets')
end

switch dataname
    
    case 'Arrhythmia'
        % Arrhythmia (420 x 279) - 12-class
        data = readtable('dataArrhytmia.xlsx','ReadVariableNames', false);
        x = data(:,1:end-1);
        x = x{:,:};
        y = data(:,end);
        y = y{:,:};

        %% Large Data Sets
    case 'Arcene'
        % ARCENE (200 x 10'000)
        data = readtable('dataArcene.xlsx','ReadVariableNames', false);
        x = data(:,2:end);
        x = x{:,:};
        y = data(:,1);
        y = y{:,:};
    case 'BreastCancerEW'
        % BreastCancerEW (569 x 30) - binary (62.74% - 37.26%)
        data = readtable('dataBreastCancerEW.xlsx','ReadVariableNames', false);
        x = data(:,2:end);
        x = x{:,:};
        y = data(:,1);
        y = y{:,:};
    
    case 'Colon'
        % Colon (62 x 2000) - binary (64.52% - 35.48%)
        data = load('colon.mat');
        x = data.X;
        y = data.Y;
        y = y + 1; % shift -1 class to 0 and 1 class to 2
        y(y==0) = 1; % set class that was originally -1 (now 0) to (+)1


    case 'bColonoscopy'
        % COLONOSCOPY (76 x 1'396)
        data = readtable('dataColonoscopy.xlsx','ReadVariableNames', false);
        x = data(:,2:end);
        x = x{:,:};
        y = data(:,1);
        y = y{:,:}; % 21 hyperplastic lesions (y=1), 15 serrated adenomas (y=2), and 40 adenoma (y=3)
        y(y==3) = 2; % combine serrated adenomas and adenomas

    case 'Colonoscopy'
        % COLONOSCOPY (76 x 1'396)
        data = readtable('dataColonoscopy.xlsx','ReadVariableNames', false);
        x = data(:,2:end);
        x = x{:,:};
        y = data(:,1);
        y = y{:,:};

    case 'CongressEW'
        % CongressEW (434 x 16) - binary (38.48% - 61.52%)
        data = readtable('dataCongressEW.xlsx','ReadVariableNames', false);
        x = data(:,1:end-1);
        x = x{:,:};
        y = data(:,end);
        y = y{:,:};

    case 'DLBCL'  
        % DLBCL (77 x 5'469)
        data=load('DLBCL.mat');
        data = data.data;
        x = data(:,2:end);
        y = data(:,1);
    
    case 'Glioma'
        % Glioma (50 x 4434) - 4-class (28.00% - 14.00% - 28.00% - 30.00%)
        data = load('GLIOMA.mat');
        x = data.X;
        y = data.Y;

    case 'Hillvalley'
        % Hillvalley (645 x 100) - binary (51.16% - 48.84%)
        data = readtable('dataHillvalley.xlsx','ReadVariableNames', false);
        x = data(:,1:end-1);
        x = x{:,:};
        y = data(:,end);
        y = y{:,:};

    case 'Kidney'
        % Kidney (156 x 24)
        data = readtable('dataKidney.xlsx','ReadVariableNames', false);
        x = data(:,1:end-1);
        x = x{:,:};
        y = data(:,end);
        y = y{:,:};

    case 'KrVsKpEW'
        % KrVsKpEW (3196 x 36) - binary
        data = readtable('dataKrVsKpEW.xlsx','ReadVariableNames', false);
        x = data(:,1:end-1);
        x = x{:,:};
        y = data(:,end);
        y = y{:,:};

    case 'Leukemia1'
        % Leukemia1 (72 x 5327) - 3-class (52.78% - 12.50% - 34.72%)
        data=load('Leukemia1.mat');
        data = data.data;
        x = data(:,2:end);
        y = data(:,1);

    case 'LSVT'
        % LSVT (126 x 310) - binary (33.33% - 66.67%)
        data = readtable('dataLSVT.xlsx','ReadVariableNames', false);
        x = data(:,1:end-1);
        x = x{:,:};
        y = data(:,end);
        y = y{:,:};
    
    case 'Lung'
        % Lung (203 x 3312) - 5-class
        data = load('Lung.mat');
        x = data.X;
        y = data.Y;

    case 'Lymphoma'
        % Lymphoma (96 x 4026) - 9-class
        data = load('Lymphoma.mat');
        x = data.X;
        y = data.Y;

    case 'Prostate'
        % Prostate (102 x 10509) - binary (50.98% - 49.02%)
        data = load('Prostate_Tumor.mat');
        data = data.data;
        x = data(:,2:end);
        y = data(:,1);

    case 'Scene'
        % Scene (2407 - 294) - binary (82.09% - 17.91%)
        data = readtable('dataScene.xlsx','ReadVariableNames', false);
        x = data(:,1:end-1);
        x = x{:,:};
        y = data(:,end);
        y = y{:,:};

    case 'Sonar'      
        % Sonar (208 x 61)
        data = readtable('dataSonar.xlsx','ReadVariableNames', false);
        x = data(:,1:end-1);
        x = x{:,:};
        y = data(:,end);
        y = y{:,:};

    case 'Spambase'
        % Spambase (4601 x 57) - binary
        data = readtable('dataSpambase.xlsx','ReadVariableNames', false);
        x = data(:,1:end-1);
        x = x{:,:};
        y = data(:,end);
        y = y{:,:};

    case 'SpectEW'
        % (267 x 23) - binary (20.60% - 79.40%)
        data = readtable('dataSpectEW.xlsx','ReadVariableNames', false);
        x = data(:,1:end-1);
        x = x{:,:};
        y = data(:,end);
        y = y{:,:};

    case 'SRBCT'
        % SRBCT (83 x 2309) - 4-class (34.94% - 30.126% - 13.25% - 21.69%)
        load("SRBCT.mat"); % when loaded like this, class is first column (otherwise last!)
        x = data(:,2:end);
        y = data(:,1);
        y = y + 1; % shift class labels to start at 1 (not 0)

    case 'WaveformEW'
        % WaveformEW (5000 x 40) - 3-class (33.84% - 33.06% - 33.10%)
        data = readtable('dataWaveformEW.xlsx','ReadVariableNames', false);
        x = data(:,1:end-1);
        x = x{:,:};
        y = data(:,end);
        y = y{:,:};

    case '11_Tumors'
        % 11_Tumors (174 x 12533) - 11-Class
        data = load('11_Tumors.mat');
        data = data.data;
        x = data(:,2:end);
        y = data(:,1);

end

%% Pre-processing
if strcmp(processing,'scale')
    %% 1. Scaling to [0,1]
    colmin = min(x);
    colmax = max(x);
    x = rescale(x,'InputMin',colmin,'InputMax',colmax);
    
    % In case of more than 2 classes, ensure no gaps between labels (e.g., no 1, 2, 4, 7 --> 1, 2, 3, 4)
    newy = zeros(size(y));
    uniquey = unique(y);
    for i = 1 : length(uniquey)
        newy(y==uniquey(i)) = i;
    end
    y = newy; % replace

    %% 2.Removing variables (colmns) with constant values

    if sum(var(x) == 0) > 0 % in case there are columns without any variation
        warning(horzcat(num2str(sum(var(x) == 0)),' Columns with constant values have been removed!'))
        x = x(:, find(var(x) ~= 0)); % Retain only columns with non-constant values
    end

end


end