function obj = validate(obj)

%% Validate the inputs
validateattributes(obj.savePath, ...
    {'char'}, {'nonempty'}, 'savePath')
validateattributes(obj.dataPath, ...
    {'char'}, {'nonempty'}, 'dataPath')
validateattributes(obj.dataWildcard, ...
    {'char'}, {'nonempty'}, 'dataWildcard')
validateattributes(obj.maskFN, ...
    {'char'}, {}, 'maskFN')
if ~isempty(obj.covarFN)
    validateattributes(obj.covarFN, ...
        {'char'}, {}, 'covarFN')
end

end
