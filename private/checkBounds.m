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
    lat_name = string('latitude');
    if (~ismember(lat_name, dimNames))
       disp('not lat-lon');
       return;
    end
    %callNames = string(fieldnames(callDims));
    dimLen = numel(dimNames);
    for(i = 1:dimLen)
        % Find which dimension we are dealing with
        %cIndex = find(strcmp(dimNames(i), callNames));
        % Time has to be treated differently because it is character string
        if strcmp(dimNames(i), 'time')
            % Get user requested bounds and convert to numeric
            udt_coord = erddap8601(callDims.time);
            % Convert dataset bounds from ISO 8601 to MATLAB datenum
            %disp(dataCoordList.time)
            dataset_times = erddap8601(string(dataCoordList.time));
            if any(isnan(udt_coord ))
                disp('Invalid time given\n');
                disp('Execution will halt\n');
                returnCode = 1;
                return;
            end
            min_call_coord = min(udt_coord);
            max_call_coord = max(udt_coord);
            min_data_coord = min(dataset_times);
            max_data_coord = max(dataset_times);
            if (min_call_coord < min_data_coord) || (max_call_coord > max_data_coord)
                disp('Dimension coordinate out of bounds\n');
                fprintf('Dimension name: %s\n', dimNames(i));
                %fprintf('Given coordinate bounds: %s to %s\n', callDims.time(1), callDims.time(2)));
                %fprintf('ERDDAP datasets bounds: %s to %s\n', datetime(min_data_coord), datetime(max_data_coord));
                returnCode = 1;
                return;
            end             
        else
            % Get user requested bounds
            min_call_coord = min(callDims.(dimNames(i)));
            max_call_coord = max(callDims.(dimNames(i)));
            % Get actual dataset bounds
            min_data_coord = min(dataCoordList.(dimNames(i)));
            max_data_coord = max(dataCoordList.(dimNames(i)));
            if (min_call_coord < min_data_coord) || (max_call_coord > max_data_coord)
                disp('Dimension coordinate out of bounds\n');
                fprintf('Dimension name: %s\n', dimNames(i));
                fprintf('Given coordinate bounds: %f to %f\n', min_call_coord, max_call_coord);
                fprintf('ERDDAP datasets bounds: %f to %f\n', min_data_coord, max_data_coord);
                returnCode = 1;
                return;
            end
        end
    end
end
