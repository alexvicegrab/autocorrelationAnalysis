function C = ls2char(D)
%%  C = ls2cell(D)
% Subsitute of "ls" command:
% Creates a char array C from the output of the inbuilt ls command

% Find files
A = ls(D);
% Put into cell array
A = textscan(A, '%s', [9:13 32]);
% Convert into char array
C = char(A{:});
