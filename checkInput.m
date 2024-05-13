function urlbase = checkInput(datasetInfo, parameter, urlbase, callDims, xlen, ylen )
% 
% Interal function to check if input is consistent and properly formed
% 
% INPUT:
%    dataInfo: result of calling erddapInfo()
%    parameter: name of parameter to extract
%    urlbase: base URL of the ERDDAP being used.
%    callDims:  dimension subset requested in initial call
%
% OUTPUT:
%  If check fails an error code
%  otherwise a possiblly modified urlbase is no trailing /
%

    % Initialize return code for error handling
    errorCode = -999;
    xlen_max = xlen;
    xlen_min = xlen;
    ylen_max = ylen;
    ylen_min = ylen;
    if(~isscalar(xlen))
        xlen_max = max(xlen, 'all', 'omitnan')/2;
        xlen_min = min(xlen, 'all', 'omitnan')/2;
    end
    if(~isscalar(ylen))
        ylen_max = max(ylen, 'all', 'omitnan')/2;
        ylen_min = min(ylen, 'all', 'omitnan')/2;
    end
        
 
    
    if(~any(strcmp('class', fieldnames(datasetInfo))))
        disp('error - datasetInfo is not a valid info structure from erddapInfo()')
        error('Function terminated with error code %d', errorCode);
    end


    % Check that the dataset is a grid
    if(~strcmp(datasetInfo.cdm_type, 'Grid'))
        disp('error - dataset is not a Grid');
        error('Function terminated with error code %d', errorCode);
    end

    allvars = string(datasetInfo.variables); 
    data_coord_names = string(datasetInfo.dimensionNames);
    callNames = string(fieldnames(callDims));

    % Test coordinate names
    namesTest = ismember(data_coord_names, callNames);
    if any(~namesTest)
        disp('Requested coordinate names do not match dataset coordinate names');
        fprintf('Requested coordinate names: %s\n', strjoin(fieldnames(callDims), ', '));
        fprintf('Dataset coordinate names: %s\n', strjoin(data_coord_names, ', '));
        error('Function terminated ');
    end


    % Check that the field given is part of the dataset
    if ~ismember(string(parameter), string(allvars))
        disp('Parameter given is not in dataset');
        disp(['Parameter given: ', parameter]);
        disp(['Dataset Parameters: ', strjoin(allvars(numel(data_coord_names)+1:end), ', ')]);
        disp('Execution halted');
        error('Function terminated');
    end
    
    % Check for non-numeric entry
    for i = 1:numel(callDims)
        if(strcmp(callNames(i), 'time'))
            udt_time = erddap8601(callDims.time);
            if(any(~isfinite(udt_time)))
                fprintf('Bad time value passed');
                error('Execution will halt\n');
            end
         else
            if any(~isfinite(callDims.(callNames(i))))
                fprintf('Bad time value passed');
                error('Execution will halt\n');
            end
         end
    end

    % check if crosses dateline, not handled yet
    if(ismember('longitude', callNames))
        lon_min = min(callDims.longitude);
        lon_max = max(callDims.longitude);
        temp_coord1 = lon_min - xlen_min;
        temp_coord2 = lon_max + xlen_max;
        if ((temp_coord1 < 180.) && (temp_coord2 > 180.)) 
            error('longtide crosses dateline - not supported');
        end
    end

    % Check that the base URL ends in /
    if ~endsWith(urlbase, '/')
        urlbase = [urlbase '/'];
    end

    % Checking URL connection to an ERDDAP - Simplified version
    try
        webread(urlbase);
    catch
        disp('Failed to connect to given ERDDAP or error in accessing ERDDAP server');
        error('Function terminated');
    end

    % If all checks pass, return the possibly modified urlbase
end
