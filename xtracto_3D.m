function [extract] = xtracto_3D(info, parameter, xpos, ypos, varargin )
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

% check tpos is the form that is required
numvarargs = length(varargin);
tpos = NaN;
if numvarargs > 0
    tpos = varargin{1};
    if(~iscellstr(tpos))
        error('tpos must be a cell-array of ISO times');
    end
end

% check that latitude and longitude exist
if( ~info.dimensions.latitude.exists || ~info.dimensions.longitude.exists)
    print('dataset must have both latitude and longitude');
    if(~info.dimensions.latitude.exists)
        print('latitude is missing');
    end
    if(~info.dimensions.longitude.exists)
        print('longitude is missing');
    end
end

xpos1 = xpos;
%convert input longitude to dataset longitudes
if(info.dimensions.longitude.lon360)
  xpos1 = make360(xpos1);
else
  xpos1 = make180(xpos1);
end



%dataStruct = getMaxTime(dataStruct,urlbase1);
[isotime, udtime, altitude, latitude, longitude] = getfileCoords(info);
tposLim = [NaN NaN];
if (info.dimensions.time.exists)
    lenTime = length(isotime);
    tpos1 = tpos;
    isLast = strfind(tpos1{1},'last');
    if(isLast > 0)
        tempTime = tpos1{1};
        tlen = size(tempTime, 2);
        arith = tempTime(5:tlen);
        tempVar = strcat('tIndex = ', num2str(lenTime), arith);
        junk = evalc(tempVar);
        tpos1{1} = isotime(tIndex);
    end
      
    isLast = strfind(tpos1{2}, 'last');
    if(isLast > 0)
        tempTime = tpos1{2};
        tlen = size(tempTime, 2);
        arith = tempTime(5:tlen);
        tempVar = strcat('tIndex = ', num2str(lenTime), arith);
        junk = evalc(tempVar);
        tpos1{2} = isotime(tIndex);
    end
    % convert time format
    dateBase = datenum('1970-01-01-00:00:00');
    secsDay = 86400;
    udtpos = NaN(2, 1);
    udtpos(1) = datenum8601(char(tpos1{1}));
    udtpos(2) = datenum8601(char(tpos1{2}));
    tposLim = [min(udtpos), max(udtpos)];
end

xposLim = [min(xpos1), max(xpos1)];
yposLim = [min(ypos), max(ypos)];


%check that coordinate bounds are contained in the dataset
result = checkBounds(info, tposLim, yposLim, xposLim);
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
[~,ind] = min(abs(latitude - latBounds(1)));
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
    myURL = myURL{1}
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

% fin
