function extractStruct = xtracto(datasetInfo, parameter, xpos, ypos, varargin)
%
% Function to extract data along a user specified track from an ERDDAP™ server
%
% INPUTS: 
%        datasetInfo - result from callng 'erddapInfo()'    
%        parameter - name of parameter to extract
%        xpos - x-axis (usually longitude) postions along track
%        ypos - y-axis (usually latitude) postions along track
% OPTIONAL INPUTS:
%  optional inputs give by passing the name of the input in quotes
%  followd by the values.  Order does not matter.
%        'tpos' - times along the track
%        'zpos' - other dimension along track,  usually 'altitude' or 'depth'
%        'xName' - name of x-coordinate,  default 'longitude'
%        'yName' - name of y-coordinate,  default 'latitude'
%        'zName' - name of z-coordinate,  default 'altitude'
%        'tName' - name of time cordinat, default 'time'
%        'xlen'- size of box around x-coordinate to make extract, default 0.
%        'ylen'- size of box around y-coordinate to make extract, default 0.
%        'zlen'- size of box around z-coordinate to make extract, default 0.
%        'urlbase' - base URL of ERDDAP™ server, default 'https://coastwatch.pfeg.noaa.gov/erddap/'
%
% OUTPUT:
%    structure where each field is of the same length as the track
%
% FIELDS:
%     mean_parameter - mean of the parameter within the bounds of that time period
%     std_parameter - standard deviation of the parameter within the bounds of that time period
%     n - number of observations in the extract at each time period
%     satellite_date - time of the actual request to the dataset at ech time period
%     requested_xName_min - minimun x-axis value in request at each time period
%     requested_xName_max - maximum x-axis value in request at each time period
%     requested_yName_min - minimun y-axis value in request at each time period
%     requested_yName_max - maximum y-axis value in request at each time period
%     requested_zName_min - minimun z-axis value in request at each time period
%     requested_zName_max - maximum z-axis value in request at each time period
%     requested_date - date given in track
%     median - median of the parameter within the bounds of that time period
%     mad - Mean absolute deviation of the parameter within the bounds of that time period


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
    addParameter(inputInfo, 'xlen', 0., @(x) iscellstr(x) || isstring(x) || isnumeric(x)); 
    addParameter(inputInfo, 'ylen', 0., @(x) iscellstr(x) || isstring(x) || isnumeric(x)); 
    addParameter(inputInfo, 'zlen', 0., @(x) iscellstr(x) || isstring(x) || isnumeric(x)); 
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
    xlen = inputInfo.Results.xlen;
    ylen = inputInfo.Results.ylen;
    zlen = inputInfo.Results.zlen;
    urlbase = inputInfo.Results.urlbase;
    track.(xName) = xpos;
    track.(yName) = ypos;
    track.(zName) = zpos;
    track.(tName) = tpos;
    
    % check the arrays are the same size
    arraySizes = structfun(@(x) length(x), track, 'UniformOutput', true);
    nonZeroElements = arraySizes ~= 0;
    arraySizes = arraySizes(nonZeroElements);
    areSameSize = all(arraySizes == arraySizes(1));
    if(~areSameSize)
        disp('Lengths of track variables do not agree')
        disp("function stops")
        return;
    end
    
    % check that is xlen either size 1 or size of xpos
    if((length(xlen) > 1) && (length(xlen) ~= length(xpos)))
        disp('xlen is of length greater than one but not the same length as xpos');
        disp('function stops');
        return;
    end
    % check that is ylen either size 1 or size of ypos
    if((length(ylen) > 1) && (length(ylen) ~= length(ypos)))
        disp('ylen is of length greater than one but not the same length as ypos');
        disp('function stops');
        return;
    end
    % warn about extend size of zlen if not empty
    if((~isempty(zpos)) && length(xlen > 1))
        if(length(zlen) == 1)
            disp('warning - zlen has a single value')
            disp('xlen and ylen have length greater than 1')
            disp('zlen will be extended to be same length with value 0')
        end
    end
    
    urlbase = checkInput(datasetInfo, parameter, urlbase, track, xlen, ylen );

    if (isscalar(xlen))
       xrad(1:numel(xpos)) = xlen;
    else
        xrad = xlen;
    end
    if (isscalar(ylen))
       yrad(1:numel(ypos)) = ylen;
    else
        yrad = ylen;
    end
    if (isscalar(zlen))
       zrad(1:numel(xpos)) = zlen;
    else
        zrad = zlen;
    end
    
    dataCoordList = getfileCoords(datasetInfo);
    if (isnumeric(dataCoordList) ) 
        error("Error retrieving coordinate variable");
    end
    track = remapCoords(datasetInfo, track, dataCoordList,  0, 0);
    time_dim = find(strcmp('time', dataCoordList));
    
    %check that coordinate bounds are contained in the dataset
    result = checkBounds(dataCoordList, track);
    if (result == 1)
        disp('Coordinates out of dataset bounds - see messages above');
        return;
    end
    
    %  create structure to store Results
    extractStruct = createOutputStructure(string(parameter), track);
    % find unique times 
    [unique_times, unique_req_time_pos] = findUniqueTimes(track.time, dataCoordList);
    no_unique_times = numel(unique_times);
    counter = 0;
    for(time_loop = 1:no_unique_times)
         %time_loop = 2;
        % now find the limits of the coordinate values for those times
        callDims = findTimeCoords(dataCoordList, unique_times(time_loop), unique_req_time_pos, time_loop, track, xrad, yrad, zrad);
        erddapCoords = findERDDAPcoords(dataCoordList, callDims);
        myURL = buildURL(datasetInfo,  parameter, erddapCoords);
        fileout='tmp.mat';
        extract = getURL(datasetInfo, myURL, fileout);
        f_names = string(fieldnames(extract));
        if (any(strcmp(f_names, 'time')))
            extract.time = string(extract.time);
        end
        extract_parameter = f_names{end,:};
        % extract gives all the values in a box for all obs at this time
        % loop on points for that Extract
        extract_point_loc = find(unique_req_time_pos == time_loop);
        no_points = numel(extract_point_loc);
        for(ipoint = 1:no_points)
            innerDim = setInnerCoords(track, extract_point_loc(ipoint), ...
                             xrad, yrad, zrad);
            erddapCoords1 = findERDDAPcoords(dataCoordList, innerDim);
            innerData = extractSubset(extract, erddapCoords1);
            counter = counter + 1;
            extractStruct = populateStruct(extractStruct,  innerData, erddapCoords1, innerDim, tpos(counter), counter);
        end
    end
end    
    % fin
