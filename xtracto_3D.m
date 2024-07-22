function [extract] = xtracto_3D(datasetInfo, parameter, xpos, ypos, varargin )
%
% Function to extract gridded from an ERDDAP™ server
%
% INPUTS: 
%        datasetInfo - result from callng 'erddapInfo()'    
%        parameter - name of parameter to extract
%        xpos - array of size 2 of x-axis (usually longitude) bounds
%        ypos - array of size 2 of y-axis (usually latitude)  bounds
%
% OPTIONAL INPUTS:
%  optional inputs give by passing the name of the input in quotes
%  followd by the values.  Order does not matter.
%        'tpos' - array of size 2 of time bounds
%        'zpos' - array of size 2 of other dimension bound,  usually 'altitude' or 'depth'
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
    % Example: addParameter(p, 'tpos', defaultTpos, @isnumeric);
    % Example: addParameter(p, 'zpos', defaultZpos, @isnumeric);
    addParameter(inputInfo, 'tpos', [], @(x) iscellstr(x) || isstring(x) || isnumeric(x)); 
    addParameter(inputInfo, 'zpos', [], @(x) iscellstr(x) || isstring(x) || isnumeric(x)); 
    addParameter(inputInfo, 'urlbase', defaultUrlName, @(x) iscellstr(x) || isstring(x) ); 

    % Parse the varargin input
    parse(inputInfo, varargin{:});

    % Extract the values
    xName = inputInfo.Results.xName;
    yName = inputInfo.Results.yName;
    zName = inputInfo.Results.zName;
    tName = inputInfo.Results.tName;
    tpos = inputInfo.Results.tpos;
    zpos = inputInfo.Results.zpos;
    urlbase = inputInfo.Results.urlbase;
    callDims.(xName) = xpos;
    callDims.(yName) = ypos;
    callDims.(zName) = zpos;
    callDims.(tName) = tpos;
    
    %datasetInfo1 = datasetInfo;
    urlbase = checkInput(datasetInfo, parameter, urlbase, callDims, 0, 0);
    dataCoordList = getfileCoords(datasetInfo);
    if (isnumeric(dataCoordList) ) 
        error("Error retrieving coordinate variable");
    end
    callDims = remapCoords(datasetInfo, callDims, dataCoordList,  0, 0);
    time_dim = find(strcmp('time', dataCoordList));
        
    %check that coordinate bounds are contained in the dataset
    result = checkBounds(dataCoordList, callDims);
    if (result == 1)
        disp('Coordinates out of dataset bounds - see messages above');
        return;
    end
    erddapCoords = findERDDAPcoords(dataCoordList, callDims);  
    
    % build the erddap url
    myURL = buildURL(datasetInfo,  parameter, erddapCoords);
    fileout='tmp.mat';
    if(iscell(myURL))
        myURL = myURL{1};
    end
    extract = getURL(datasetInfo, myURL, fileout);
    f_names = fieldnames(extract);
    extract_parameter = f_names{end,:};
    if (strcmp('time', f_names))
        extract.time = string(extract.time);
    end
    
    % check if latitude is north-south and rotate if it is
    if (strcmp('latitude', f_names))
       if(extract.latitude(2) < extract.latitude(1))
         lat_index = find(strcmp('latitude', f_names));
         latSize = size(extract.latitude);
         extract.latitude = flipud(extract.latitude);
         extract.(extract_parameter) = rotatedArray(extract.(extract_parameter), lat_index);
       end
    end
    %  put longitudes back on the requestors scale
    %  reqeust is on (0,360), data is not
    if (strcmp('longitude', f_names))
        if (max(xpos) > 180.)
           extract.longitude = make360(extract.longitude);
        elseif (min(xpos) < 0.)
        %request is on (-180,180)
           extract.longitude = make180(extract.longitude);
        end
    end
end    
    % fin
