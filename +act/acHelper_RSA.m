function accuracy = autocorrelation_torque_RSA(autocorrelationFn, eventDur)

%% Parameters
fprintf('loading %s\n', autocorrelationFn)

outputFN = fullfile(fileparts(autocorrelationFn), 'DMLT_simulation_RSA.mat');

if exist(outputFN, 'file')
    accuracy = [];
    load(outputFN)
else
    %% DMLT
    obj = struct;
    load(autocorrelationFn)

    accuracy = nan(size(eventDur));
    
    tic
    trilNaN = tril(nan(size(obj.simMat))) + ones(size(obj.simMat));
    
    for e = eventDur
        % Explaining variable
        predictor = ceil(mod((1-0.001):(obj.numVols-0.001), 2 * e) / e)';
        
        % Predictor matrix
        [X, Y] = meshgrid(predictor);
        P = X == Y;
        P = P .* trilNaN;
        
        [h, p, ci, stats] = ttest2(obj.simMat(P == 1), obj.simMat(P==0));
        
        accuracy(e == eventDur) = stats.tstat;
    end
    toc
    
    save(outputFN, 'accuracy')
end

end
