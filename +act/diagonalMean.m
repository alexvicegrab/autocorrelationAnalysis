function S = diagonalMean(M)
%%  S = diagonalMean(M)
% Calculates means from the leading diagonal to all the lower ones
% Very fast through indexing
lengthM = length(M);

% Indices of diagonal
F = find(eye(lengthM));

% Mean result for each diagonal
S = nan(1,lengthM);

for c = 1:lengthM
    % Average diagonal element
    tmp = M(F);
    S(c) = mean(tmp(~isnan(tmp)));
    
    % Slide indices of diagonal down
    F = F(1:end-1) + 1;
end
end
