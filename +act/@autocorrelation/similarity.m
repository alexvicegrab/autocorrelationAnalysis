function obj = similarity(obj)
%% SIMILARITY Run similarity metric over volumes
% obj = obj.similarity

switch obj.metric
    case 'corr'
        obj.simMat = corrcoef(obj.dataMat);
    case 'spearman'
        obj.simMat = corr(obj.dataMat, 'type', 'Spearman');
    case 'partialcorr'
        obj.simMat = partialcorr(obj.dataMat);
    case 'euclid'
        obj.simMat = squareform(pdist(obj.dataMat', 'euclidean'));
    case 'mahalanobis'
        % If matrix is close to singular or badly scaled, we may see NaNs...
        dbstop if warning
        obj.simMat = squareform(pdist(obj.dataMat', 'mahalanobis'));
    otherwise
        error('No such similarity metric')
end

% Lower triangle of similarity matrix
obj.tril = tril( true(length(obj.simMat)), -1);

% Temporal distance between volumes
[X, Y] = meshgrid(1:length(obj.simMat));
obj.dist = abs(X-Y);

end
