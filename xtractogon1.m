function [extract, xlon, xlat, xtime] = xtractogon1(datasetInfo, parameter, xpoly, ypoly, varargin);
% 
% Function XTRACTOGON downloads a 3-D data chunk 
% and applies a two-D spatial mask along the t-axis.
%
% INPUTS:
% 
% tpos gives min/max time in matlab days (e.g., datenum (year,month,day))
% id - numerical or string code for remote data set - complete list is given
%          in the xtracto_3D_bdap.m 
% polyfile = xy vector file (space-delimitered lon lat, ) that defines
%             the polygon.  If it is not closed, the program will do this
%                           automatically.
%
%  OUTPUTS:
%  extract(t,z,y,x) = 4-Dimensional array containing desired data.
%  xlon, xlat, xtime - basis vectors of extract array.
%    For satellite data, the only index of z is 1, and z(1) = 0.  Th
%
%  Dependencies:  requires xtracto_3D_bdap.m
%    http://coastwatch.pfel.noaa.gov/xfer/xtracto/matlab
%
% CoastWatch
% 15 Mar 08
% DGF
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
    addParameter(inputInfo, 'tpos', [], @(x) iscellstr(x) || isnumeric(x)); 
    addParameter(inputInfo, 'zpos', [], @(x) iscellstr(x) || isnumeric(x)); 

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
        temp_time = erddap8601(tpos)
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
    if (xpoly(end) ~= xpoly(1)) | (ypoly(end) ~= ypoly(1)) 
         xpoly(end+1) = xpoly(1);
         ypoly(end+1) = ypoly(1);
    end
    
    % make mask (1 = in or on), (nan = out)
    [xlon xlat] = meshgrid(extract.longitude, extract.latitude);
    inPoly = inpolygon(xlon, xlat, xpoly, ypoly);
    if (no_time == 1)
        extract.(parameter)(~inPoly) = NaN
    else
        for (i = 1:no_time)
            extract.(parameter)(i, ~inPoly) = NaN;    
        end
    end
end
    % fin
