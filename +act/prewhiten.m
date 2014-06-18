function [X, W, mu_X] = prewhiten(X)
%PREWHITEN Performs prewhitening of a dataset X
%
%   [X, W, mu_X] = prewhiten(X)
%
% Performs prewhitening of the dataset X. Prewhitening concentrates the main
% variance in the data in a relatively small number of dimensions, and
% removes all first-order structure from the data. In other words, after
% the prewhitening, the covariance matrix of the data is the identity
% matrix. The function returns the subtracted data mean in mu_X, and the
% applied linear mapping in W.

% ADAPTED FROM...
% Toolbox for Dimensionality Reduction => http://homepage.tudelft.nl/19j49
% (C) Laurens van der Maaten, Delft University of Technology

% Compute and apply the ZCA mapping
mu_X = mean(X, 1);
X = bsxfun(@minus, X, mu_X);
mappedX = X / sqrtm(cov(X));
if nargout > 1
    W = X \ mappedX;
end
   
end
