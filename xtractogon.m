function [extract, xlon, xlat, xtime] = xtractogon(datasetInfo, parameter, xpoly, ypoly, varargin);
% 
% Function to extract data in a polygon from an ERDDAP™ server
%
% INPUTS: 
%        datasetInfo - result from callng 'erddapInfo()'    
%        parameter - name of parameter to extract
%        xpoly - array of x-axis (usually longitude) polygon values
%        ypoly - array of y-axis (usually latitude)  polygon values
%
% OPTIONAL INPUTS:
%  optional inputs give by passing the name of the input in quotes
%  followd by the values.  Order does not matter.
%        'tpos' - array of size 2 of time bounds
%        'zpos' - array of size 2 of other dimension bound,  usually 'altitude' or 'depth'
%                 each element must be the same
%        'xName' - name of x-coordinate,  default 'longitude'
%        'yName' - name of y-coordinate,  default 'latitude'
%        'zName' - name of z-coordinate,  default 'altitude'
%        'tName' - name of time cordinat, default 'time'
%        'urlbase' - base URL of ERDDAP™ server, default 'https://coastwatch.pfeg.noaa.gov/erddap/'
%
% OUTPUT:
%    structure containing:
%         tpos values  - 1D array
%         zpos values  - 1D array
%         ypos values  - 1D array
%         xpos values  - 1D array
%         parameter values - matrix with same numbr of dimension as the dataset
%

    % Create an instance of the inputParser class.
    inputInfo = inputParser;

    % Set the default values for the optional parameters.
    defaultXName = "longitude";
    defaultYName = "latitude";
    defaultZName = "altitude"; 
    defaultTName = "time"; 
    defaultUrlName = 'https://coastwatch.pfeg.noaa.gov/erddap/'; 

    % Setup validation functions for string inputs
    mustBeTextScalar = @(x) ischar(x) || (isstring(x) && isscalar(x));
    
    % Add optional name-value pairs
    addParameter(inputInfo, 'xName', defaultXName, mustBeTextScalar);
    addParameter(inputInfo, 'yName', defaultYName, mustBeTextScalar);
    addParameter(inputInfo, 'zName', defaultZName, mustBeTextScalar);
    addParameter(inputInfo, 'tName', defaultTName, mustBeTextScalar);
     
    % For numerical parameters, if they have default values, initialize them similarly
    % Here assuming they don't have default values and thus not adding a default value
    % Example: addParameter(p, 'tpoly', defaultTpos, @isnumeric);
    % Example: addParameter(p, 'zpos', defaultZpos, @isnumeric);
    addParameter(inputInfo, 'tpos', [], @(x) iscellstr(x) || isstring(x) || isnumeric(x)); 
    addParameter(inputInfo, 'zpos', [], @(x) iscellstr(x) || isstring(x) || isnumeric(x)); 

    % Parse the varargin input
    parse(inputInfo, varargin{:});

    % Extract the values
    xName = inputInfo.Results.xName;
    yName = inputInfo.Results.yName;
    zName = inputInfo.Results.zName;
    tName = inputInfo.Results.tName;
    tpos = inputInfo.Results.tpos;
    zpos = inputInfo.Results.zpos;
    callDims.(xName) = xpoly;
    callDims.(yName) = ypoly;
    callDims.(zName) = zpos;
    callDims.(tName) = tpos;

    if(~any(strcmp('class', fieldnames(datasetInfo))))
        disp('error - datasetInfo is not a valid info structure from erddapInfo()')
        error('Function terminated with error code %d', errorCode);
    end


    % Check that the dataset is a grid
    if(~strcmp(datasetInfo.cdm_type, 'Grid'))
        disp('error - dataset is not a Grid');
        error('Function terminated with error code %d', errorCode);
    end
    
    % check polygons are of same length
    if(numel(xpoly) ~= numl(ypoly))
        disp('xpoly and ypoly of unequal length')
        error('function terminated')
    end


    f_names = fieldnames(callDims);
    xmin = min(xpoly); 
    xmax = max(xpoly);
    ymin = min(ypoly);
    ymax = max(ypoly);
    erddapCoord.(xName) = [xmin xmax];
    erddapCoord.(yName) = [ymin ymax];
    if (~isempty(zpos))
        zmin = min(zpos);
        zmax = max(zpos);
        erddapCoord.(zName) = [zmin zmax];
    end
    if (~isempty(tpos))
        % convert to numbers to compare
        temp_time = erddap8601(tpos);
        [min_time,  min_index] = min(temp_time);
        [max_time,  max_index] = max(temp_time);
        erddapCoord.time = [tpos(min_index) tpos(max_index)];
    end
    % Initialize an empty cell array for extra dimension

    extract = dynamicFunctionCall('xtracto_3D', datasetInfo, parameter, erddapCoord);
    extract.(parameter) = squeeze(extract.(parameter));
    
    f_names = fieldnames(extract);
    xtime = NaN;
    % we want to mask for each time period
    if (strmatch('time', f_names))
       no_time = numel(string(extract.time));
    else
        no_time = 1;
    end
    % make sure polygon is closed; if not, close it.
    if (xpoly(end) ~= xpoly(1)) || (ypoly(end) ~= ypoly(1)) 
         xpoly(end+1) = xpoly(1);
         ypoly(end+1) = ypoly(1);
    end
    
    % make mask (1 = in or on), (nan = out)
    [xlon, xlat] = meshgrid(extract.longitude, extract.latitude);
    inPoly = inpolygon(xlon, xlat, xpoly, ypoly);
    if(no_time == 1)
        extract.(parameter)(~inPoly) = NaN;
    else
        for(i = 1:no_time)
            extract.(parameter)(i, ~inPoly) = NaN;    
        end
    end
end
    % fin
