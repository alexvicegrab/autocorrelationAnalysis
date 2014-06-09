function obj = simPerVolume(obj)
%%SIMPERVOLUME Calculates the similarity per volume and detects outliers
% obj = obj.simPerVolume();

% Obtain similarity by volume
meanSim = mean(obj.simMat, 2);
smoothSim = smooth( 1:length(meanSim), meanSim, 0.1, 'rloess' );

obj.sim_byVol = meanSim - smoothSim;

% Find outliers (robust std with bottom 95% of distribution)
distrSim = sort(obj.sim_byVol, 'descend');
distrSim = distrSim( 1 : round(0.95 * length(distrSim)) );
stdSim = std(distrSim);

obj.outlierVol = obj.sim_byVol < -stdSim * 5;

% Make outlier mask
obj.outlierMask = meshgrid(~obj.outlierVol);
obj.outlierMask = double(obj.outlierMask & obj.outlierMask');
obj.outlierMask(~obj.outlierMask) = NaN;
obj.outlierMask(logical(eye(obj.numVols))) = NaN;

end
