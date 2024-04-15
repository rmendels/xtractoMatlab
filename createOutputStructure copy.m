function temp_struct = createOutputStructure(tempCoords, dataInfo, dataX, dataY, dataZ, datatime, parameter, callDims)
    % Initialize an empty structure
    temp_struct = struct();

    % Assign provided arguments to the structure
    temp_struct.param = tempCoords.param;
    temp_struct.datasetid = dataInfo.datasetid;
    temp_struct.dataX = dataX;
    temp_struct.dataY = dataY;

    % Assign dataZ and datatime based on callDims content
    if ~isempty(callDims{3})
        temp_struct.dataZ = dataZ;
    else
        temp_struct.dataZ = [];  % Or assign NaN or another placeholder if more appropriate
    end

    if ~isempty(callDims{4})
        temp_struct.datatime = datatime;
    else
        temp_struct.datatime = [];  % Or assign NaN or another placeholder if more appropriate
    end

    % Rename fields based on the 'etopo' condition
    if ~isempty(regexp(temp_struct.datasetid, 'etopo', 'once'))
        % Define new names for the 'etopo' condition
        newNames = {'depth', 'datasetname', 'X', 'Y', 'Z', 'time'};
    else
        % Define new names for the non-'etopo' condition, using 'parameter'
        newNames = {parameter, 'datasetname', 'X', 'Y', 'Z', 'time'};
    end

    % Rename fields
    temp_struct = renameFields(temp_struct, {'param', 'datasetid', 'dataX', 'dataY', 'dataZ', 'datatime'}, newNames);
end

% Function to rename fields of a structure
function structOut = renameFields(structIn, oldNames, newNames)
    structOut = struct();
    for i = 1:length(oldNames)
        if isfield(structIn, oldNames{i})
            structOut.(newNames{i}) = structIn.(oldNames{i});
        end
    end
end
