function obj = timeseries(obj)
%% TIMESERIES Get summary stats from timeseries
% obj = obj.timeseries

obj.seriesMean = mean( obj.dataMat );
obj.seriesStd = std( obj.dataMat);
obj.seriesSEM = obj.seriesStd ./ sqrt(obj.numVox);
obj.seriesMedian = median (obj.dataMat);
obj.seriesMin = min (obj.dataMat);
obj.seriesMax = max (obj.dataMat);

end
