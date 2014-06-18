function obj = acHelper(cellArray)

% Helps run the process stream with a set of parameters
obj = act.autocorrelation( cellArray{:} );
obj = obj.process;
