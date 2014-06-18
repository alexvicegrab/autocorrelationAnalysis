function obj = plotTimeseries(obj)
%PLOTTIMESERIES Plots the this autocorrelation dataset
%   obj = obj.plotTimeseries();

obj = obj.getFigHandle();

subplot(1,1,1)
hold on

if ~isempty(which('shadedErrorBar'))
    % Shaded error bars
    shadedErrorBar(1:obj.numVols, obj.seriesMean, ...
        3 * obj.seriesSEM, '-r', 0);
    shadedErrorBar(1:obj.numVols, obj.seriesMean, ...
        2 * obj.seriesSEM, '-g', 0);
    shadedErrorBar(1:obj.numVols, obj.seriesMean, ...
        obj.seriesSEM, {'-b', 'LineWidth', 1}, 0);
else
    warning('AUTOCORR:plot', 'shadedErrorBar function not found, using plot instead')
    plot(1:obj.numVols, obj.seriesMean + 3 * obj.seriesSEM, 'g')
    plot(1:obj.numVols, obj.seriesMean - 3 * obj.seriesSEM, 'g')
    plot(1:obj.numVols, obj.seriesMean + 2 * obj.seriesSEM, 'g')
    plot(1:obj.numVols, obj.seriesMean - 2 * obj.seriesSEM, 'g')
    plot(1:obj.numVols, obj.seriesMean + 1 * obj.seriesSEM, 'g')
    plot(1:obj.numVols, obj.seriesMean - 1 * obj.seriesSEM, 'g')
    plot(1:obj.numVols, obj.seriesMean, 'k')
    
end

title('Timeseries');
ylabel('Signal')
xlabel('Volumes')

end
