function [extractStruct] = xtracto1(datasetInfo, parameter, xpos, ypos, varargin)
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
    addParameter(inputInfo, 'tpos', [], @(x) iscellstr(x) || isnumeric(x)); 
    addParameter(inputInfo, 'zpos', [], @(x) iscellstr(x) || isnumeric(x)); 
    addParameter(inputInfo, 'xlen', [], @(x) iscellstr(x) || isnumeric(x)); 
    addParameter(inputInfo, 'ylen', [], @(x) iscellstr(x) || isnumeric(x)); 
    addParameter(inputInfo, 'zlen', [], @(x) iscellstr(x) || isnumeric(x)); 

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
    zlen = inputInfo.Results.ylen;
    track.(xName) = xpos;
    track.(yName) = ypos;
    track.(zName) = zpos;
    track.(tName) = tpos;
    if (numel(xlen) == 1)
       xrad(1:numel(xpos)) = xlen;
    else
        xrad = xlen;
    end
    if (numel(ylen) == 1)
       yrad(1:numel(ypos)) = ylen;
    else
        yrad = ylen;
    end
    if (numel(zlen) == 1)
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
    extractStruct = createStruct(parameter);
    % find unique times 
    [unique_times unique_req_time_pos] = findUniqueTimes(track.time, dataCoordList.time);
    no_unique_times = numel(unique_times);
    for time_loop = 1:no_unique_times
        % now find the limits of the coordinate values for those times
        callDims = findTimeCoords(dataCoordList, unique_times(time_loop), unique_req_time_pos, time_loop, track, xrad, yrad, zrad);
        erddapCoords = findERDDAPcoords(dataCoordList, callDims);
        myURL = buildURL(datasetInfo,  erddapCoords);
        fileout='tmp.mat';
        extract = getURL(datasetInfo, myURL, fileout);
        f_names = fieldnames(extract);
        extract_parameter = f_names{end,:};
        % extract gives all the values in a box for all obs at this time
        % loop on points for that Extract
        extract_point_loc = find(unique_req_time_pos == time_loop);
        no_points = numel(extract_point_loc);
        for ipoint = 1:no_points
            % first set up 
            innerDim = setInnerCoords(track, extract_point_loc(ipoint), ...
                         xrad, yrad, zrad);
            erddapCoords1 = findERDDAPcoords(dataCoordList, innerDim);
        end
    end
    
    % loop on points
    % initialize array to store last reqeust
    extractTemp = ones(1,11)*NaN;     
    % create arrays to store last indices of last call
    oldLonIndex = int32(zeros(2, 1));
    oldLatIndex = int32(zeros(2, 1));
    oldTimeIndex =  int32(zeros(2, 1));
    newLonIndex = int32(zeros(2, 1));
    newLatIndex =  int32(zeros(2, 1));
    newTimeIndex =  int32(zeros(2, 1));
    
    
    for i = 1:size(xpos, 2)
    
    
      % define bounding box
      xmax = xpos1(i) + xrad(i)/2;
      xmin = xpos1(i) - xrad(i)/2;
      if(info.dimensions.latitude.lat_south)
         ymax = ypos(i) + yrad(i)/2;
         ymin = ypos(i) - yrad(i)/2;
      else
         ymin = ypos(i) + yrad(i)/2;
         ymax = ypos(i) - yrad(i)/2;
      end
    % find closest time of available data
    %map request limits to nearest ERDDAP coordinates
       [~,ind] = min(abs(latitude - ymin));
       newLatIndex(1) = ind;
       [~,ind] = min(abs(latitude - ymax));
       newLatIndex(2) = ind;
       [~,ind] = min(abs(longitude - xmin));
       newLonIndex(1) = ind;
       [~,ind] = min(abs(longitude - xmax));
       newLonIndex(2) = ind;
       if (info.dimensions.time.exists)
           [~,ind] = min(abs(udtime- udtpos(i)));
           newTimeIndex(1)=ind;
       end
       if (info.dimensions.time.exists)
          samecall_test =  isequal(newLatIndex, oldLatIndex) && isequal(newLonIndex, oldLonIndex) && isequal(newTimeIndex(1), oldTimeIndex(1));
       else
          samecall_test =  isequal(newLatIndex, oldLatIndex) && isequal(newLonIndex, oldLonIndex);
       end       
       if(samecall_test)
         % the call will be the same as last time, so no need to repeat
           extract(i,:) = extractTemp;
       else
      %map request limits to nearest ERDDAP coordinates
           erddapLats = NaN(2,1);
           erddapLons = NaN(2,1);
           erddapLats(1) = latitude(newLatIndex(1));
           erddapLats(2) = latitude(newLatIndex(2));
           erddapLons(1) = longitude(newLonIndex(1));
           erddapLons(2) = longitude(newLonIndex(2));
           erddapTimes = cell(2,1);
           if (info.dimensions.time.exists)
               requesttime=isotime(newTimeIndex(1));
               erddapTimes(1)=requesttime;
               erddapTimes(2)=requesttime;
           end
    % build the erddap url
           myURL = buildURL(info, parameter, erddapTimes, altitude, erddapLats, erddapLons);
           fileout='tmp.mat';
           if (iscell(myURL))
               myURL = myURL{1};
           end
           downLoadReturn = getURL(info, myURL, fileout);
           paramExp = strcat('param=downLoadReturn.', parameter);
           junk = evalc(paramExp);
           param = squeeze(param);
           if (~isfloat(param))
               param = double(param);
           end
     %    [param, lon, lat, time]= getURL(myURL{1},fileout,dataStruct);
          % get array dimensions - note that the order of data returned is not the same   
           paramIndex=find(~isnan(param));
           extract(i,1) = mean(param(paramIndex));
           extract(i,2) = std(param(paramIndex));       
           extract(i,3) = length(paramIndex);
           extract(i,4) = NaN;
           extract(i,5) = xmin;
           extract(i,6) = xmax;
           extract(i,7) = ymin;
           extract(i,8) = ymax;
           extract(i,9) = NaN;
           extract(i,10) = median(param(paramIndex));
           extract(i,11) = mad(param(paramIndex));
           if (info.dimensions.time.exists)
               extract(i,4) = datenum8601(char(erddapTimes(1)));
               extract(i,9) = udtpos(i);
           end
        end
    end
    mean_name = strcat('mean ', parameter);
    std_name = strcat('std ', parameter);
    median_name = strcat('median ', parameter);
    mad_name = strcat('mad ', parameter);
    if (info.dimensions.time.exists)
        extractStruct=struct(mean_name, extract(:,1), std_name, extract(:,2), 'nobs', extract(:,3), ...
           'extractTime', datestr(extract(:,4)), 'lonmin', extract(:,5), ...
           'lonmax', extract(:,6), 'latmin', extract(:,7), 'latmax', extract(:,8), ...
           'requestTime', datestr(extract(:,9)), median_name, extract(:,10), mad_name, extract(:,11));
    else
        extractStruct=struct(mean_name, extract(:,1), std_name, extract(:,2), 'nobs', extract(:,3), ...
           'extractTime', extract(:,4), 'lonmin', extract(:,5), ...
           'lonmax', extract(:,6), 'latmin', extract(:,7), 'latmax', extract(:,8), ...
           'requestTime', extract(:,9), median_name, extract(:,10), mad_name, extract(:,11));
    end
end    
    % fin
