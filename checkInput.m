function urlbase = checkInput(dataInfo, parameter, urlbase, callDims)
    % Initialize return code for error handling
    errorCode = -999;

    % Check that a valid rerddap info structure is being passed
    if ~isstruct(dataInfo) % Approximation: Checking if dataInfo is a structure
        disp('error - dataInfo is not a valid info structure from rerddap');
        error('Function terminated with error code %d', errorCode);
    end

    % Check that the dataset is a grid
    if ~isfield(dataInfo, 'alldata') || ~strcmp(dataInfo.alldata.NC_GLOBAL.value, 'Grid')
        disp('error - dataset is not a Grid');
        error('Function terminated with error code %d', errorCode);
    end

    % Assume getallvars and dimvars are implemented or replace with equivalent
    allvars = getallvars(dataInfo); % Placeholder for actual implementation
    allCoords = dimvars(dataInfo); % Placeholder for actual implementation

    % Assuming callDims is a cell array or structure with non-empty fields
    % MATLAB does not support direct filtering like R, so this part is conceptual
    % Filtering non-empty fields if callDims is a structure

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
    if ~ismember(parameter, allvars)
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
    % MATLAB does not have a direct equivalent to httr::HEAD, but you can use
    % webread or urlread wrapped in a try-catch to attempt to connect to the server
    try
        webread(urlbase);
    catch
        disp('Failed to connect to given ERDDAP or error in accessing ERDDAP server');
        error('Function terminated with error code %d', -1000);
    end

    % If all checks pass, return the possibly modified urlbase
end

% Note: This translation assumes placeholders for `getallvars` and `dimvars` functions,
% which need to be defined based on how they interact with the `dataInfo` structure.
