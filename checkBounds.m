function returnCode = checkBounds(dataCoordList, callDims)
% Internal function to check if request to xtracto.m,
% xtracto_3D.m and xtractogon.m are within bounds
% of the dataset
%
% INPUTS:  
%    dataCoordList: coordinates of the requested dataset from  getfileCoords.m.
%    callDims:  dimension subset requested in initial call
%
% OUTPUT:  
%     0 if callDims is within bounds
%     1 if not within bounds
%
    returnCode = 0;
    dimNames = string(fieldnames(dataCoordList));
    callNames = string(fieldnames(callDims));
    dimLen = numel(dimNames);

    for i = 1:dimLen
        % Find which dimension we are dealing with
        cIndex = find(strcmp(dimNames(i), fieldnames(dimargs)));

        % Time has to be treated differently because it is character string
        if strcmp(dimNames(i), 'time')
            % Get user requested bounds and convert to numeric
            udt_coord = erddap8601(callDims.erddap8601);

            % Convert dataset bounds from ISO 8601 to MATLAB datenum
            dataset_time = erddap8601(dataCoordList.(dimNames(i)));

            % Check for NA equivalent in MATLAB (NaN)
            if any(isnan(call_times))
                fprintf('Invalid time given\n');
                fprintf('Execution will halt\n');
                returnCode = 1;
            end
            min_call_coord = min(udt_coord);
            max_call_coord = max(udt_coord);
            min_data_coord = min(dataset_times);
            max_data_coord = max(dataset_times);
        else
            % Check for non-numeric entry
            if any(~isfinite(callDims.(dimNames(i))))
                fprintf('Non-numeric entry in %s\n', dimNames(i));
                fprintf('Execution will halt\n');
                returnCode = 1;
            end
            % Get user requested bounds
            % Get actual dataset bounds
            min_call_coord = min(callDims.(dimNames(i)));
            max_call_coord = max(callDims.(dimNames(i)));
            min_data_coord = min(dataCoordList.(dimNames(i)));
            max_data_coord = max(dataCoordList.(dimNames(i)));
        end

        % Skip longitude bound check if cross_dateline_180 is true
        %if ~(strcmp(dimNames(i), 'longitude') && cross_dateline_180)
            if (min_call_coord < min__data_coord) || (max_call_coord > max_data_coord)
                fprintf('Dimension coordinate out of bounds\n');
                fprintf('Dimension name: %s\n', dimNames(i));
                if strcmp(dimNames(i), 'time')
                    fprintf('Given coordinate bounds: %s to %s\n', datestr(min_call_coord), datestr(max_call_coord));
                    fprintf('ERDDAP datasets bounds: %s to %s\n', datestr(min_data_coord), datestr(max_data_coord));
                else
                    fprintf('Given coordinate bounds: %f to %f\n', min_call_coord, max_call_coord);
                    fprintf('ERDDAP datasets bounds: %f to %f\n', min_data_coord, max_data_coord);
                end
                returnCode = 1;
            end
        %end
    end

    if returnCode ~= 0
        fprintf('Coordinates out of dataset bounds - see messages above\n');
    end
end
