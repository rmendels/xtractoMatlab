function returnCode = checkBounds1(dataCoordList, dimargs, cross_dateline_180)
    returnCode = 0;
    dimNames = fieldnames(dataCoordList);
    dimLen = numel(dimNames);

    for i = 1:dimLen
        % Find which dimension we are dealing with
        cIndex = find(strcmp(dimNames{i}, fieldnames(dimargs)));

        % Time has to be treated differently because it is character string
        if strcmp(dimNames{i}, 'time')
            % Get user requested bounds and convert to numeric
            min_dimargs = min(datenum(dimargs.(dimNames{i}), 'yyyy-mm-ddTHH:MM:SS'));
            max_dimargs = max(datenum(dimargs.(dimNames{i}), 'yyyy-mm-ddTHH:MM:SS'));

            % Convert dataset bounds from ISO 8601 to MATLAB datenum
            temp_time = datenum(dataCoordList.(dimNames{i}), 'yyyy-mm-ddTHH:MM:SS');

            % Check for NA equivalent in MATLAB (NaN)
            if any(isnan(temp_time))
                fprintf('Invalid time given\n');
                fprintf('Execution will halt\n');
                returnCode = 1;
            end

            min_coord = min(temp_time);
            max_coord = max(temp_time);
        else
            % Check for non-numeric entry
            if any(~isfinite(dimargs.(dimNames{i})))
                fprintf('Non-numeric entry in %s\n', dimNames{i});
                fprintf('Execution will halt\n');
                returnCode = 1;
            end
            
            % Get user requested bounds
            min_dimargs = min(dimargs.(dimNames{i}));
            max_dimargs = max(dimargs.(dimNames{i}));
            % Get actual dataset bounds
            min_coord = min(dataCoordList.(dimNames{i}));
            max_coord = max(dataCoordList.(dimNames{i}));
        end

        % Skip longitude bound check if cross_dateline_180 is true
        if ~(strcmp(dimNames{i}, 'longitude') && cross_dateline_180)
            if (min_dimargs < min_coord) || (max_dimargs > max_coord)
                fprintf('Dimension coordinate out of bounds\n');
                fprintf('Dimension name: %s\n', dimNames{i});
                if strcmp(dimNames{i}, 'time')
                    fprintf('Given coordinate bounds: %s to %s\n', datestr(min_dimargs), datestr(max_dimargs));
                    fprintf('ERDDAP datasets bounds: %s to %s\n', datestr(min_coord), datestr(max_coord));
                else
                    fprintf('Given coordinate bounds: %f to %f\n', min_dimargs, max_dimargs);
                    fprintf('ERDDAP datasets bounds: %f to %f\n', min_coord, max_coord);
                end
                returnCode = 1;
            end
        end
    end

    if returnCode ~= 0
        fprintf('Coordinates out of dataset bounds - see messages above\n');
    end
end
