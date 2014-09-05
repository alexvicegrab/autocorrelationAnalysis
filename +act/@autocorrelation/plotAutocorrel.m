function obj = plotAutocorrel(obj)
%PLOTAUTOCORREL Plots the this autocorrelation dataset
%   obj = obj.plotAutocorrel();

% <<< Hardcoded for the time being >>>
numBins = 100;

obj = obj.getFigHandle();

subplot(2,2,1)
imagesc(obj.simMat .* obj.outlierMask)
colorbar
axis equal tight
title('Autocorr. Matrix');
xlabel('Volumes')
ylabel('Volumes')

subplot(2,2,2)
act.scatter2heat(...
    obj.simMat(obj.tril), ...
    obj.dist(obj.tril), [], ...
    { linspace( min(obj.simMat(obj.tril)), ...
    max(obj.simMat(obj.tril)), ...
    numBins ), numBins}, ...
    'log');
axis square tight
title('Autocorr. Heatmap');
xlabel('Correlation Coefficient')
ylabel('Volumes')

subplot(2,2,3)
hold on
plot(1:obj.numVols, obj.sim_byVol, '.k');
plot(find(obj.outlierVol), obj.sim_byVol(obj.outlierVol), 'or');
xlim([0, obj.numVols+1])
title(sprintf('Average corr. per vol. (%d excluded)', sum(obj.outlierVol)));
xlabel('Volume')
ylabel('Mean residual correlation')

subplot(2,2,4)
hold on
plot(1:obj.numVols-1, obj.sim_byDist, '.k');
xlim([0, obj.numVols])
title(sprintf('Average corr. per distance'));
xlabel('Volume')
ylabel('Mean correlation')

end
