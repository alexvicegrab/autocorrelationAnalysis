function obj = masking(obj)
% Mask data using prespecified mask

if ~isempty(obj.maskFN)
    fprintf('Masking data with...\n');    
    
    obj.maskMat = true;
    for m = 1:size(obj.maskFN, 1)
        fprintf('\t%s\n', obj.maskFN(m,:));
        obj.maskMat = obj.maskMat & ...
            spm_read_vols( spm_vol( ls (deblank( obj.maskFN(m,:) ))));
    end
    
    if any(obj.dimVols ~= size(obj.maskMat))
        error('Mask size is different from data size')
    end
    
    obj.maskMat = logical(obj.maskMat);
else
    fprintf('No masking\n');
    obj.maskMat = ones(obj.dimVols);
end

obj.maskMat = and(obj.maskMat, all(isfinite(obj.dataMat), 4)); % Exclude non-finite elements (logical mask)
obj.maskMat = and(obj.maskMat, all(obj.dataMat ~= 0, 4)); % Exclude zero elements (logical mask)

% Shift dimensions by 3 (x, y, z, vols becomes vols, x, y, z)
obj.dataMat = shiftdim(obj.dataMat, 3);

% Load all of obj.dataMat (except zero elements)
obj.dataMat = obj.dataMat(:, obj.maskMat);
obj.dataMat = obj.dataMat'; % [voxels, volumes]

obj.numVox = size(obj.dataMat, 1);

fprintf('...data size is %d x %d...\n', obj.numVox, obj.numVols);   
end
