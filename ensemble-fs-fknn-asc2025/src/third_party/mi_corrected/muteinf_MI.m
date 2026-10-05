function info = muteinf_MI(A, Y)
% minimally corrected version to address the problem of only working for
% binary +1/-1 classes (need to match +1/-1)

n = size(A,1);
Z = [A Y];
if(n/10 > 20)
    nbins = 20;
else
    nbins = max(floor(n/10),10);
end;
pA = hist(A, nbins);
pA = pA ./ n;

i = find(pA == 0);
pA(i) = 0.00001;

%% CHANGE 1 of 2: count ALL classes (any labels), not only +1/-1
classes = unique(Y);
cl = numel(classes);
pY = zeros(1,cl);
for i=1:cl
    pY(i) = length(find(Y==classes(i)));
end
pY = pY / n;
% ===== END CHANGE 1 =====

p = zeros(cl,nbins);
rx = abs(max(A) - min(A)) / nbins;
for i = 1:cl
    xl = min(A);
    for j = 1:nbins
        %% CHANGE 2 of 2: select observations of class i by its actual label
        interval = (xl <= Z(:,1)) & (Z(:,2) == classes(i));
        % ===== END CHANGE 2 =====
        if(j < nbins)
            interval = interval & (Z(:,1) < xl + rx);
        end;
        %find(interval)
        p(i,j) = length(find(interval));
        
        if p(i,j) == 0 % hack!
            p(i,j) = 0.00001;
        end
        
        xl = xl + rx;
    end
end
i = find(pY == 0);
pY(i) = 0.00001;

HA = -sum(pA .* log(pA));
HY = -sum(pY .* log(pY));
pA = repmat(pA,cl,1);
pY = repmat(pY',1,nbins);
p = p ./ n;
info = sum(sum(p .* log(p ./ (pA .* pY)))); % Mutual Information