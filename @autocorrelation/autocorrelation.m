classdef autocorrelation
    %AUTOCORRELATION Specialises in calculating autocorrelation
    %
    % Properties:
    % savePath      = Where to save data?
    % dataPath      = Where does the raw data reside?
    % dataWildcard  = Wildcard for loading data ['*.nii]
    % [TR]          = Repetition Time of fMRI acquisition
    % [maskFN]      = Name/wildcard of masking file (e.g. GM mask)
    % [covarFN]     = Name/wildcard of covariates file (e.g. realignment)
    % [covarNames]  = Cell array containing names of covariates
    % metric        = Name of similarity metric to use ['corr']    
    % analyses      = Cell array of analyses to run:
    %               'whiten': whitens the data
    % verbose       = Do we print out diagnostic text and images? [false]
    % keep_raw      = Do we save the raw (but denoised) data? [true]
    
    properties
        savePath
        dataPath
        dataWildcard    = '*.nii'
        TR
        maskFN
        covarFN
        covarNames      = {'x', 'y', 'z', 'p', 'r', 'j'}
        metric          = 'corr'
        analyses
        
        verbose         = true
        keep_raw        = true
    end
    
    properties (SetAccess = 'protected')
        figHandle
        
        volumes         % Number of columns
        numVols         % Number of volumes in raw data        
        dimVols         % Size of each vol in X, Y, Z direction
        numVox          % Number of voxels in raw data
        
        simMat          % Similarity matrix measure
        sim_byVol       % Mean similarity by volume
        sim_byDist      % Mean similarity by distance vector
        outlierVol      % Outlier vols (calculated from sim_byVol)
        outlierMask     % Outlier mask for plotting
        
        dataMat         % Temporary data structure
        maskMat         % Mask used on data
        tril            % Lower triangle of data (for visualisation)
        dist            % Relative temporal distance between volumes
        
        covarVec        % Covariate vector
        covarMat        % Covariate matrix
        
        % Timeseries stats
        seriesMean      % mean
        seriesStd       % standard deviation
        seriesSEM       % standard error of the mean
        seriesMedian    % median
        seriesMin       % minimum
        seriesMax       % maximum
        
        % Save data as...
        processFN = 'autocorrelation.mat'
    end
    
    methods
        function obj = autocorrelation(varargin)
            % Construct our object
            fieldNames = fieldnames(obj);
            
            % Parse options
            for f = 1:2:length(varargin)
                if ismember(varargin{f}, fieldNames)
                    obj.(varargin{f}) = varargin{f+1};
                else
                    error('Unrecognized fieldname %s', varargin{f});
                end
            end
            
            obj = obj.validate();
        end
    end
    
    %% Static methods
    methods (Static = true)
        
        function obj = helper(cellArray)
            % Helps run the process stream with a set of parameters
            obj = autocorrelation( cellArray{:} );
            obj = obj.process;
        end
        
        function S = diagonalMean(M)
            %%  S = diagonalMean(M)
            % Calculates means from the leading diagonal to all the lower ones
            % Very fast through indexing
            lengthM = length(M);
            
            % Indices of diagonal
            F = find(eye(lengthM));
            
            % Mean result for each diagonal
            S = nan(1,lengthM);
            
            for c = 1:lengthM
                % Average diagonal element
                tmp = M(F);
                S(c) = mean(tmp(~isnan(tmp)));
                
                % Slide indices of diagonal down
                F = F(1:end-1) + 1;
            end
        end
        
        function [scatterMatrix, bins]= scatter2heat(X, Y, C, bins, transform)
            % SCATTER2HEAT
            % scatterMatrix = scatter2heat(X, Y, C, bins, transform)
            % Plots a memory efficient scatterplot by creating a heatmap
            % Adapted from mathematical.coffee at stackoverflow.com
            %
            % Inputs:
            % X: x axis points of scatterplot
            % Y: y axis points of scatterplot
            % C: how to colour the points (if empty, the heatmap will contain number of
            % points in that bin)
            % bins: how many bins in each direction...
            
            if nargin < 4
                % Group into bins of 0.05
                bins = 20;
            end
            if nargin < 5
                % Group into bins of 0.05
                transform = '';
            end
            if length(bins) == 1
                bins = {bins, bins};
            elseif length(bins) == 2
                if ~iscell(bins)
                    bins = mat2cell(bins);
                end
            else
                error('Not the right length of bins...')
            end
            
            % Create the bins
            if length(bins{1}) == 1;
                bins{1} = linspace(min(X), max(X), bins{1});
            end
            if length(bins{2}) == 1;
                bins{2} = linspace(min(Y), max(Y), bins{2});
            end
            
            % Work out which bin each X and Y is in (idxx, idxy)
            [nx, idxx] = histc(X, bins{1});
            [ny, idxy] = histc(Y, bins{2});
            
            % Calculate mean (or number of points) in each direction
            if nargin < 3 || isempty(C);
                scatterMatrix = accumarray([idxy idxx], ones(size(X))', [], @sum);
            else
                scatterMatrix = accumarray([idxy idxx], C', [], @mean);
            end
            
            if ~isempty(transform)
                eval(['scatterMatrix = ' transform '(scatterMatrix);']);
            end
            
            %% PLOT
            imagesc(bins{1}, bins{2}, scatterMatrix)
            set(gca, 'YDir', 'normal') % flip Y axis back to normal
            colorbar
        end
        
        function [X] = whiten(X, fudgefactor)
            %% Whitening function
            % Dr. Patrick Mineault 2011
            % http://xcorr.net/2011/05/27/whiten-a-matrix-matlab-code/
                        
            % Subtract mean from X
            X = bsxfun(@minus, X, mean(X));
            
            % Get eigenvector of cross product
            A = X'*X;
            [V, D] = eig(A);
            
            if nargin < 2 || isempty(fudgefactor)
                fudgefactor = median(diag(D));
            end
            
            % Whiten matrix
            X = X * V * diag(1./ (diag(D) + fudgefactor) .^ (1/2)) * V';
        end        
    end
end
