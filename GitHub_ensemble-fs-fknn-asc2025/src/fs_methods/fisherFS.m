function [fisher, ranked] = fisherFS(x,y)
% Fisher Score

meanx = mean(x);
classes = unique(y(:));
fisher = zeros(size(x,2),1);
numerator = zeros(size(x,2),1);
denominator = zeros(size(x,2),1);

for i = 1:size(x,2)

    % determine numerator and denominator values for each feature
    for j = 1:numel(classes)
        idx = (y == classes(j));
        numerator(i) = numerator(i) + sum(idx) * (mean(x(idx,i)) - meanx(i))^2;
        denominator(i) = denominator(i) + sum(idx) * var(x(idx,i));
    end

    % Avoid dividing by zero -> set to zero
    if denominator(i) > 0
        fisher(i) = numerator(i) / denominator(i);
    else
        fisher(i) = 0;
    end

end

[~,ranked] = sort(fisher,'descend');

