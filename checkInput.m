function urlbase = checkInput(datasetInfo, parameter, urlbase, callDims)
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
    
    if(~any(strcmp('class', fieldnames(datasetInfo))
        disp('error - datasetInfo is not a valid info structure from erddapInfo()')
        error('Function terminated with error code %d', errorCode);
    end


    % Check that the dataset is a grid
    if(~strcmp(datasetInfo.cdm_type, 'Grid'))
        disp('error - dataset is not a Grid');
        error('Function terminated with error code %d', errorCode);
    end

    allvars = datasetInfo.variables; 
    allCoords = datasetInfo.dimensionNames;

    % Test coordinate names
    namesTest = ismember(fieldnames(callDims), allCoords);
    if any(~namesTest)
        disp('Requested coordinate names do not match dataset coordinate names');
        fprintf('Requested coordinate names: %s\n', strjoin(fieldnames(callDims), ', '));
        fprintf('Dataset coordinate names: %s\n', strjoin(allCoords, ', '));
        error('Function terminated with error code %d', errorCode);
    end

    if numel(fieldnames(callDims)) ~= numel(allCoords)
        disp('Ranges not given for all of the dataset dimensions');
        disp('Coordinates given: ');
        disp(fieldnames(callDims));
        disp('Dataset Coordinates: ');
        disp(allCoords);
        disp('Execution halted');
        error('Function terminated with error code %d', errorCode);
    end

    % Check that the field given is part of the dataset
    if ~ismember(string(parameter), string(allvars))
        disp('Parameter given is not in dataset');
        disp(['Parameter given: ', parameter]);
        disp(['Dataset Parameters: ', strjoin(allvars(numel(allCoords)+1:end), ', ')]);
        disp('Execution halted');
        error('Function terminated with error code %d', errorCode);
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
        error('Function terminated with error code %d', -1000);
    end

    % If all checks pass, return the possibly modified urlbase
end
