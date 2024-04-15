function [inputInfo] = callDims(dataInfo, parameter, xpos, ypos, varargin )
% Example script to get the large chunks of data via SWFSC/ERD THREDDS server
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
    defaultXName = "Longitude";
    defaultYName = "Latitude";
    defaultZName = "Altitude"; 
    defaultTName = "Time"; 
    % Add optional name-value pairs
    addParameter(inputInfo, 'xName', defaultXName, @ischar);
    addParameter(inputInfo, 'yName', defaultYName, @ischar);
    addParameter(inputInfo, 'zName', defaultZName, @ischar);
    addParameter(inputInfo, 'tName', defaultTName, @ischar);
    
    % For numerical parameters, if they have default values, initialize them similarly
    % Here assuming they don't have default values and thus not adding a default value
    % Example: addParameter(p, 'tpos', defaultTpos, @isnumeric);
    % Example: addParameter(p, 'zpos', defaultZpos, @isnumeric);
    addParameter(inputInfo, 'tpos', [], @iscellstr); % Assuming no default, will remain empty if not provided
    addParameter(inputInfo, 'zpos', [], @isnumeric); % Assuming no default, will remain empty if not provided
end