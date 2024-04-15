function [callDims] = getCallDims(callStruct)

    fields = fieldnames(callStruct);
    
    % Initialize cell array with two columns: one for field names, one for values
    %temp = cell(, 2);
    temp(1) = callStruct.xName
    temp(2) = callStruct.yName
    no_dim = 2;
    if (~isempty(callStruct.tpos))
       no_dim = no_dim + 1;
       temp(no_dim) = 'time'
    end
    if (~isempty(callStruct.zpos))
       no_dim = no_dim + 1;
       temp(no_dim) = callStruct.zName
    end
    callDims = temp;
end
