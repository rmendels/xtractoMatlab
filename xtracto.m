function extractStruct = xtracto(datasetInfo, parameter, xpos, ypos, varargin)
% Script to grab data along a user specified track
%
% INPUTS:  xpos = longitude (in decimal degrees East, either 0-360 or -180 to 180)
%          ypos = latitude (in decimal degrees N; -90 to 90)
%          tpos = time (preferably in matlab [JUlien] days)
%          dtype = data ID Code (data types listed below)
%          xrad = length of search box in longitude (decimal degrees)
%          yrad = length of search box in latitude (decimal degrees)
% 
% xpos=[230 235];
% ypos=[40 45];
% tpos=cellstr(['2006-01-15';'2006-01-20']);
% xlen=0.5;
% ylen=0.5;
% extract=xtracto(xpos, ypos,tpos, 20, xlen, ylen);
% extract=xtracto(xpos, ypos, tpos,'phssta8day', xlen, ylen);


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
    track.(xName) = xpos;
    track.(yName) = ypos;
    track.(zName) = zpos;
    track.(tName) = tpos;
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
    
    %result = checkBounds(info, tposLim, yposLim, xposLim);
    %if(isnan(result))
    %  disp('Coordinates out of dataset bounds - see messages above');
    %  return;
    %end
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
