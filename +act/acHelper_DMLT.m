function accuracy = autocorrelation_torque_DMLT(autocorrelationFn, eventDur, classifier)
if nargin < 3
    classifier = dml.svm;
else
    classifier = eval(classifier);
end

%% Parameters
fprintf('loading %s\n', autocorrelationFn)

outputFN = fullfile(fileparts(autocorrelationFn), sprintf('DMLT_simulation_%s.mat', class(classifier)));

if exist(outputFN, 'file')
    accuracy = [];
    load(outputFN)
else
    %% DMLT
    obj = struct;
    load(autocorrelationFn)

    accuracy = nan(size(eventDur));
    
    crossvalidator = dml.crossvalidator('mva', classifier);
    
    tic
    for e = eventDur
        % Explaining variable
        predictor = ceil(mod((1-0.001):(obj.numVols-0.001), 2 * e) / e)';
        
        crossvalidator = crossvalidator.train(obj.dataMat, predictor);
        
        accuracy(e == eventDur) = crossvalidator.statistic('accuracy');
    end
    toc
    
    save(outputFN, 'accuracy')
end

end
