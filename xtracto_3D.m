function [extract] = xtracto_3D(datasetInfo, parameter, xpos, ypos, varargin )
% Function to get gridded from an ERDDAP srver
%
% INPUTS:  
%          info = result of call to function info()
%          parameter = name of parameter to use from dataset referenced in
%          info
%          xpos = [xmin xmax] = longitude in 0 to 360 E lon, or -180 to 180 E lon
%          ypos = [ymin ymax] = latitude -90 to 90 N lat
%          tpos = [tpos tmax] = time, in matlab days  
% 
% OUTPUT:
%
%  Extract = 4 dimensional array
%            index 1 = time dimension of output array
%            index 2 = depth dimension of output array
%            index 3 = latitude dimension of output array
%            index 4 = longitude dimension of output array
%
%  lon = longitude vector (basis of column 4)
%  lat = latitude vector (basis of col 3)
%  time = time vector (basis for column 1)
% 
%
% Sample Calls:
%
% to extract Seawifs 8-day Primary Productivity 
% [extract] = xtracto_3D(xpos,ypos,tpos,'41');
%
%  to extract pathfinder SST 8-day mean data 
%  [extract] = xtracto_3D(xpos,ypos,tpos,'18');
%
% %
% see the following link to get data codes and full data set information
% 
%
% V0.1  17 Aug 2006.
% CoastWatch/DGF
% v1.0 DGF  22 Feb 2007 - Cleaned up code and help
% v1.1 DGF  27 Feb 2007 - More cleaning
% v1.2 DGF  9 June 2007 - tweaked the dataid handling to pass
%                         through CWBrowser requests 
% v1.3 DGF 13 May 2011  - adjusted script to handle adjustment to coastwatch server
%tpos{1} = '2006-05-05';
%tpos{2} = '2006-06-21';
%extract=xtracto_3D([230 240], [40 45],tpos, 20);

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
