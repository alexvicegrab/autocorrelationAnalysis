function obj = process(obj)

obj.processFN = fullfile(obj.savePath, obj.processFN);

if exist(obj.processFN, 'file')
    fprintf('Already done, not repeating: %s\n', obj.processFN);
    if obj.verbose
        load(obj.processFN)
    end
else
    %% Get 4d data
    % Load image headers using SPM
    dataHdr = spm_vol(...
        ls(fullfile(obj.dataPath, obj.dataWildcard)));
    
    % Load images themselves
    obj.dataMat = spm_read_vols(dataHdr);
    
    obj.numVols = size(obj.dataMat, 4);
    obj.dimVols = [size(obj.dataMat, 1), size(obj.dataMat, 2), size(obj.dataMat,3)];
    obj.numVox = prod(obj.dimVols);
    
    %% Analysis proper
    % Mask data
    obj = obj.masking();
    
    if obj.numVox > 5 % NEED TO SET THIS LIMIT TO A PROPERTY...
        
        % Denoise obj.dataMat
        obj = obj.denoise_dataMat();
        
        obj = obj.timeseries();
        
        % Similarity analysis
        obj = obj.similarity();
        
        obj = obj.simPerVolume();
        
        % Temporal Distance
        obj.sim_byDist = act.diagonalMean(obj.simMat);
        obj.sim_byDist(1) = [];
    end
    
    if ~obj.keep_raw
        obj.dataMat = []; % Clear dataMat
    end
    
    %% Save autoC
    if ~exist(fileparts(obj.processFN), 'dir')
        mkdir(fileparts(obj.processFN));
    end
    save(obj.processFN, 'obj');
    disp('Finished autocorrelation analysis')
end

%% Plots
if obj.verbose && obj.numVox > 0
    obj.plotAutocorrel();
    pause(1)
    imgPath = fullfile(obj.savePath, 'autocorrelation.eps');
    print(obj.figHandle, '-depsc ', imgPath);
    
    obj.plotTimeseries();
    pause(1)
    imgPath = fullfile(obj.savePath, 'timeseries.eps');
    print(obj.figHandle, '-depsc ', imgPath);
end

end
