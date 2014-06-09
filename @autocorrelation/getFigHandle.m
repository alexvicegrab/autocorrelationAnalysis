function obj = getFigHandle( obj )
%GETFIGHANDLE Get figure handle
%   If there is a figure handle, call figure with that handle
%   Otherwise, create new figure and store its handle in object

if isempty(obj.figHandle)
    obj.figHandle = figure;
else
    figure(obj.figHandle);
end

end

