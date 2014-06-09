function obj = covariates(obj)
% Obtain covariates from file

if ~isempty(obj.covarFN)
    obj.covarFN = deblank(ls(obj.covarFN));
    
    % Get covariates
    obj.covarVec = load(obj.covarFN);
    
    % Get them the right way up
    if size(obj.covarVec, 1) < size(obj.covarVec, 2)
        obj.covarVec = obj.covarVec';
    end
    
    obj.covarMat = nan(size(obj.covarVec, 1), size(obj.covarVec, 1), size(obj.covarVec, 2));
    for c = 1:size(obj.covarVec,2)
        obj.covarMat(:,:,c) = squareform(pdist(obj.covarVec(:,c)));
    end
else
   obj.covarVec = [];
   obj.covarMat = [];
end

end
