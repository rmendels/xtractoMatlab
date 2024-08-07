function tcoord1 = removeLast(isotime, tcoord1)
% Internal function to convert a time request of 'last' to actual time
%
% INPUTS:
%   isotime - dataset timess in ISO format 
%   tcoord1 - request times
%
% OUTPUTS:
%        tcoord1 - time coordinate with 'last' converted to ISO time.
%

    lenTime = length(isotime);

    for i = 1:2
        if contains(tcoord1{i}, 'last')
            % Extract the arithmetic operation after 'last'
            arith = extractAfter(tcoord1{i}, 'last');
            
            % Create the expression and evaluate it
            tempVar = strcat(num2str(lenTime), arith);
            tIndex = eval(tempVar);  % Use eval to evaluate the arithmetic expression
            
            % MATLAB arrays are 1-based, ensure tIndex is within bounds
            tIndex = max(1, min(tIndex, lenTime));
            
            % Replace the 'last...' with the corresponding isotime value
            tcoord1{i} = isotime{tIndex};
        end
    end

    % Assuming udtpos and tcoordLim are not required for the MATLAB version,
    % or need to be adapted separately.
end
