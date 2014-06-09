function obj = denoise_dataMat(obj)

for a = 1:length(obj.analyses)
    switch obj.analyses{a}
        case 'covariate'
            % Get covariates
            obj = obj.covariates();
            
            %% Denoise using covariates
            if ~isempty(obj.covarVec)
                
                fprintf('Denoising data using %s\n', obj.covarFN)
                
                %% Linearly denoised analysis with motion...
                % Regress out motion parameters...
                
                for n = 1:size(obj.dataMat, 1)
                    b = glmfit(obj.covarVec, obj.dataMat(n,:));
                    % Remove variance due to motion regressors...
                    obj.dataMat(n,:) = obj.dataMat(n,:) - b(2:end)' * obj.covarVec';
                end
            else
                error('You have not specified any covariates')
            end
            
        case 'whiten'
            
            %% Denoise using whitening
            fprintf('Whitening data\n')
            
            obj.dataMat = autocorrelation.whiten(obj.dataMat);
        case 'highpassSPM'
            
            % Let's first set up the parameters...
            K = struct;
            K.row = 1:obj.numVols;
            K.RT = obj.TR;
            
            % << Hard coded typical cut-off period >>
            K.HParam = 128;
            
            fprintf('Highpass data at %0.2f\n', K.HParam)
            
            if (obj.TR * obj.numVols) < K.HParam
                error('The data length is shorter than the cutoff of the filter')
            end
            
            obj.dataMat = spm_filter(K, obj.dataMat')';
        
        case 'lowpassFourier'
            % Bandpass filter to remove frequencies above/below respiration
            %{
            L = size(obj.dataMat, 2);
            NFFT = 2^nextpow2(L);
            f = Fs/2*linspace(0,1,NFFT/2+1);
            
            Y = fft(obj.dataMat, NFFT, 2) / L;
            
            plot(f, log(mean(2*abs(Y(:, 1:NFFT/2+1)))))
            %}
            %%
            
            % Respiration has a WaveLength of ~4.5 seconds or so 
            RespWL = 10; %4.5;
            Fs = 1 / obj.TR;
            FiltFQ = RespWL * Fs;
            
            fprintf('Highpass data at %0.2f\n', FiltFQ)
            
            Y = fft(obj.dataMat, [], 2);
            
            Y(:, floor(obj.numVols / 2 - FiltFQ) + 1 : ceil(obj.numVols / 2 + FiltFQ) + 1) = 0;
            
            obj.dataMat = ifft(Y, [], 2);
            
            % plot(log(mean(2*abs(Y(:, 1:NFFT/2+1)))))
        otherwise
            error('No such denoise_dataMat method')
    end
end
end
