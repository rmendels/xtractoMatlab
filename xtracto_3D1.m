function [extract] = xtracto_3D(dataInfo, parameter, xpos, ypos, varargin )
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
    p = inputParser;

    % Set the default values for the optional parameters.
    defaultXName = "Longitude";
    defaultYName = "Latitude";
    defaultZName = "Altitude"; 
    % Add optional name-value pairs
    addParameter(p, 'xName', defaultXName, @ischar);
    addParameter(p, 'yName', defaultYName, @ischar);
    addParameter(p, 'zName', defaultZName, @ischar);
    
    % For numerical parameters, if they have default values, initialize them similarly
    % Here assuming they don't have default values and thus not adding a default value
    % Example: addParameter(p, 'tpos', defaultTpos, @isnumeric);
    % Example: addParameter(p, 'zpos', defaultZpos, @isnumeric);
    addParameter(p, 'tpos', [], @iscellstr); % Assuming no default, will remain empty if not provided
    addParameter(p, 'zpos', [], @isnumeric); % Assuming no default, will remain empty if not provided

    % Parse the varargin input
    parse(p, varargin{:});

    % Extract the values
    xName = p.Results.xName;
    yName = p.Results.yName;
    zName = p.Results.zName;
    tpos = p.Results.tpos;
    zpos = p.Results.zpos;
    
    dataInfo1 = dataInfo;
    urlbase = dataInfo.access.urlBase;
    urlbase <- checkInput(dataInfo1, parameter, urlbase, callDims);
    if (isnumeric(urlbase)) 
       if (urlbase == -999) 
          error("error in inputs");
      else 
        error('url is not a valid erddap server');
      end
    end    
    
    
    check tpos is the form that is required
    if (~isempty(tpos))
        if(~iscellstr(tpos))
            error('tpos must be a cell-array of ISO times');
        end
    end    
    
    
    dataCoordList = getfileCoords(dataInfo);
    if (isnumeric(dataCoordList) ) 
        error("Error retrieving coordinate variable");
    end
    working_coords = remapCoords(dataInfo1, callDims, dataCoordList,  urlbase);
    dataInfo1 = working_coords$dataInfo1;
    cross_dateline_180 = working_coords$cross_dateline_180;
    xcoordLim = working_coords.xcoord1;
    ycoordLim  = [min(working_coords.ycoord1), max(working_coords.ycoord1)];
    
    zcoordLim = NaN;
    if (~isnan(working_coords.zcoord1)) 
       zcoordLim = working_coords.zcoord1;
       if (numel(zcoordLim) == 1)
           zcoordLim <- [zcoordLim, zcoordLim];
       end
    end
    
    tcoordLim = [NaN, NaN];
    if (~isnan(working_coords.tcoord1)) 
        % check for last in time,  and convert
        isoTime  = dataCoordList$time;
        udtTime = datenum(isoTime, 'yyyy-mm-ddTHH:MM:SS');
        tcoord1 = removeLast(isoTime, working_coords.tcoord1);
        tcoord1 = datenum(tcoord1, 'yyyy-mm-ddTHH:MM:SS');
        tcoordLim = tcoord1;
    end
    
    dimargs = struct(xName, xcoordLim, yName, ycoordLim, zName, zcoordLim, tName, tcoordLim);
    % Get a list of field names
    fieldNames = fieldnames(dimargs);
    % Loop through each field, checking if it's empty
    for i = length(fieldNames):-1:1
        if isempty(dimargs.(fieldNames{i}))
            % Remove the field if it's empty
            dimargs = rmfield(dimargs, fieldNames{i});
        end
    end
    
    %check that coordinate bounds are contained in the dataset
    result = checkBounds1(info, tposLim, yposLim, xposLim);
    if (isnan(result))
      disp('Coordinates out of dataset bounds - see messages above');
      return;
    end
    
    
    % get list of available time periods
    
    % define spatial bounding box
    lonBounds = [min(xpos1) max(xpos1)];
    if(info.dimensions.latitude.lat_south)
      latBounds = [min(ypos) max(ypos)];
    else
       latBounds = [max(ypos) min(ypos)];
    end
    
    %map request limits to nearest ERDDAP coordinates
    erddapLats = NaN(2, 1);
    erddapLons = NaN(2, 1);
    erddapTimes = cell(2, 1);
    size(latitude)
    size(latBounds)
    [~,ind] = min(abs(latitude - latBounds(1)));
    ind
    erddapLats(1) = latitude(ind);
    [~,ind] = min(abs(latitude - latBounds(2)));
    erddapLats(2) = latitude(ind);
    [~,ind] = min(abs(longitude - lonBounds(1)));
    erddapLons(1)=longitude(ind);
    [~,ind] = min(abs(longitude - lonBounds(2)));
    erddapLons(2)=longitude(ind);
    if (info.dimensions.time.exists)
        [~,ind] = min(abs(udtime - tposLim(1)));
        erddapTimes(1) = isotime(ind);
        [~,ind] = min(abs(udtime - tposLim(2)));
        erddapTimes(2) = isotime(ind);
    end
    
    
    % build the erddap url
    myURL = buildURL(info, parameter, erddapTimes, altitude, erddapLats, erddapLons);
    fileout='tmp.mat';
    if(iscell(myURL))
        myURL = myURL{1};
    end
    extract = getURL(info, myURL, fileout);
    f_names = fieldnames(extract);
    extract_parameter = f_names{end,:};
    
    % check if latitude is north-south and rotate if it is
    if (length(extract.latitude) > 1)
       if(extract.latitude(2) < extract.latitude(1))
          latSize = size(extract.latitude);
          extract.latitude = flipud(extract.latitude);
          % kluge - do by brute force to deal with different number of
          % coordinates
          if (info.dimensions.time.exists)
              % has altitude
              if(~isnan(altitude))
                  cmd = strcat('extract.', parameter, '= extract.', parameter, '(:, :, fliplr(1:latSize(1)), :)');
              else
                  cmd = strcat('extract.', parameter, '= extract.', parameter, '(:, fliplr(1:latSize(1)), :)');
              end
          else
              % has altitude
              if(~isnan(altitude))
                  cmd = strcat('extract.', parameter, '= extract.', parameter, '(:, fliplr(1:latSize(1)), :)');
              else
                  cmd = strcat('extract.', parameter, '= extract.', parameter, '(fliplr(1:latSize(1)), :)');
              end
          end
          junk = evalc(cmd);
       end
    end
    junk = evalc(strcat('extract.', extract_parameter, '= squeeze(extract.', extract_parameter,')'));
    %  put longitudes back on the requestors scale
    %  reqeust is on (0,360), data is not
    if (max(xpos) > 180.)
       extract.longitude = make360(extract.longitude);
    elseif (min(xpos) < 0.)
    %request is on (-180,180)
       extract.longitude = make180(extract.longitude);
    end
    %change time to isotime
    if (info.dimensions.time.exists)
        extract.time = (extract.time/secsDay) + dateBase;
        extract.time = datestr(extract.time);
    end
end    
    % fin