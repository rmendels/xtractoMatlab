function [extract] = xtracto_3D(xpos,ypos,tpos,dtype)
% Example script to get the large chunks of data via SWFSC/ERD THREDDS server
%
% INPUTS:  xpos = [xmin xmax] = longitude in 0 to 360 E lon, or -180 to 180 E lon
%          ypos = [ymin ymax] = latitude -90 to 90 N lat
%          tpos = [tpos tmax] = time, in matlab days  
%          dtype = data ID Code (data types listed below)
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
%extract=xtracto_3D([230 240], [40 45],['2006-05-05'; '2006-06-21'], 18)

% default URL for NMFS/SWFSC/ERD  THREDDS server
 urlbase='http://coastwatch.pfeg.noaa.gov/erddap/griddap/';
 urlbase1='http://coastwatch.pfeg.noaa.gov/erddap/tabledap/allDatasets.csv?';
 
load('erddapStruct.mat','erddapStruct');
%erddapStruct(1)
structLength=size(erddapStruct);
dtypename=cell(structLength(1),1);
for i=1:structLength(1);
     dtypename{i}=erddapStruct(i,1).dtypename;
end;
% make sure data type input is a string and not a number
if ischar(dtype);
  datatype = find(strcmp(dtypename,dtype), 1);
  if(isempty(datatype));
    disp('dataset name: ', dtype);
    disp('no matching dataset found');
    return;      
  end;
else
  datatype = dtype;
  if ((datatype < 1) || (datatype > structLength(1)));
    disp('dataset number out of range - must be between 1 and 107: ', datatype);
    disp('routine stops');
    return;
  end;
end
dataStruct = erddapStruct(datatype);
dataStruct = getMaxTime(dataStruct,urlbase1);

xpos1=xpos;
%convert input longitude to dataset longitudes
if(dataStruct.lon360);
  xpos1=make360(xpos1);
else
  xpos1=make180(xpos1);
end;


% Bathymetry is a special case lets get it out of the way
if(strcmp(dataStruct.datasetname,'etopo360')||strcmp(dataStruct.datasetname,'etopo180'));
  [extract, result]=getETOPO(dataStruct,xpos1,ypos,urlbase);
   if(result== -1);
       error('error in getting ETOPO data - see error messages');
   else
      return;
   end;
end;


%convert time format
%dateBase= datenum('1970-01-01-00:00:00');
%secsDay = 86400;
tposLen=size(tpos);
udtpos=NaN(tposLen(1),1);
tpos1=cellstr(tpos);
for i=1:tposLen(1);
   udtpos(i)=datenum8601(tpos1{i});
end;

xposLim=[min(xpos1), max(xpos1)];
yposLim=[min(ypos), max(ypos)];
tposLim=[min(udtpos), max(udtpos)];


%check that coordinate bounds are contained in the dataset

result=checkBounds(dataStruct,xposLim,yposLim,tposLim);
if(isnan(result));
  disp('Coordinates out of dataset bounds - see messages above');
  return;
end;


% get list of available time periods
[isotime, udtime, latitude,longitude, altitude]=getfileCoords(dataStruct, urlbase);

% define spatial bounding box
lonBounds=[min(xpos1) max(xpos1)];
if(dataStruct.latSouth);
  latBounds=[min(ypos) max(ypos)];
else
   latBounds=[max(ypos) min(ypos)];
end;

%map request limits to nearest ERDDAP coordinates
erddapLats= NaN(2,1);
erddapLons= NaN(2,1);
erddapTimes=cell(2,1);
[~,ind] = min(abs(latitude - latBounds(1)));
erddapLats(1)=latitude(ind);
[~,ind] = min(abs(latitude - latBounds(2)));
erddapLats(2)=latitude(ind);
[~,ind] = min(abs(longitude- lonBounds(1)));
erddapLons(1)=longitude(ind);
[~,ind] = min(abs(longitude - lonBounds(2)));
erddapLons(2)=longitude(ind);
[~,ind] = min(abs(udtime- tposLim(1)));
erddapTimes(1)=isotime(ind);
[~,ind] = min(abs(udtime - tposLim(2)));
erddapTimes(2)=isotime(ind);


% build the erddap url
myURL = buildURL(dataStruct,erddapLons,erddapLats,erddapTimes,urlbase);
fileout='tmp.mat';
extract = getURL(myURL{1},fileout,dataStruct);
% check if latitude is north-south and rotate if it is
if(extract.latitude(2) < extract.latitude(1));
   latSize=size(extract.latitude);
   extract.latitude=flipud(extract.latitude);
   cmd=strcat('extract.',varname,'=extract.',varname,'(:,fliplr(1:latSize(1)),:)' );
   junk=evalc(cmd);
end;
%  put longitudes back on the requestors scale
%  reqeust is on (0,360), data is not
if (max(xpos) > 180.);
   extract.longitude=make360(extract.longitude);
elseif (min(xpos) < 0.);
%request is on (-180,180)
   extract.longitude=make180(extract.longitude);
end;
% fin
