function [extractStruct] = xtracto(xpos,ypos,tpos,dtype,xlen,ylen)
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



% default URL for NMFS/SWFSC/ERD  THREDDS server
 urlbase='http://coastwatch.pfeg.noaa.gov/erddap/griddap/';
 urlbase1='http://coastwatch.pfeg.noaa.gov/erddap/tabledap/allDatasets.json?';

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
    tempStr=strcat('dataset name: ', num2str(dtype));
    disp(tempStr);
    disp('no matching dataset found');
    return;      
  end;
else
  datatype = dtype;
  if ((datatype < 1) || (datatype > structLength(1)));
    tempStr=strcat('dataset number out of range - must be between 1 and 107: ', num2str(datatype));
    disp(tempStr);
    disp('routine stops');
    return;
  end;
end
extract=ones(size(tpos,1),11)*NaN;     
dataStruct = erddapStruct(datatype);
xpos1=xpos;
%convert input longitude to dataset longitudes
if(dataStruct.lon360);
  xpos1=make360(xpos1);
else
  xpos1=make180(xpos1);
end;

% Bathymetry is a special case lets get it out of the way
if(strcmp(dataStruct.datasetname,'etopo360')||strcmp(dataStruct.datasetname,'etopo180'));
  [extractStruct, result]=getETOPOtrack(dataStruct,xpos1,ypos,xlen,ylen,urlbase);
   if(result== -1);
       error('error in getting ETOPO data - see error messages');
   else
      return;
   end;
end;
dataStruct = getMaxTime(dataStruct,urlbase1);
tposLen=size(tpos,1);
udtpos=NaN(tposLen(1),1);
tpos1=cellstr(tpos);
for i=1:tposLen(1);
   udtpos(i)=datenum8601(tpos1{i});
end;

if length(xlen) == 1;
   xrad(1:length(xpos1)) = xlen;
else
    xrad=xlen;
end;
if length(ylen) == 1;
   yrad(1:length(ypos)) = ylen;
else
    yrad=ylen;
end;
xposLim=[min(xpos1-xrad/2), max(xpos1+xrad/2)];
yposLim=[min(ypos-yrad/2), max(ypos+yrad/2)];
tposLim=[min(udtpos), max(udtpos)];

%check that coordinate bounds are contained in the dataset

result=checkBounds(dataStruct,xposLim,yposLim,tposLim);
if(isnan(result));
  disp('Coordinates out of dataset bounds - see messages above');
  return;
end;

% get coordinate values
[isotime, udtime, latitude,longitude, altitude]=getfileCoords(dataStruct, urlbase);


% loop on points
% initialize array to store last reqeust
extractTemp=ones(1,11)*NaN;     
% create arrays to store last indices of last call
oldLonIndex= int32(zeros(2,1));
oldLatIndex= int32(zeros(2,1));
oldTimeIndex=  int32(zeros(2,1));
newLonIndex= int32(zeros(2,1));
newLatIndex=  int32(zeros(2,1));
newTimeIndex=  int32(zeros(2,1));


for i = 1:size(tpos,1);


  % define bounding box
  xmax = xpos(i)+xrad(i)/2;
  xmin = xpos(i)-xrad(i)/2;
  if(dataStruct.latSouth);
     ymax=ypos(i)+yrad(i)/2;
     ymin=ypos(i)-yrad(i)/2;
  else
     ymin=ypos(i)+yrad(i)/2;
     ymax=ypos(i)-yrad(i)/2;
  end;
% find closest time of available data
%map request limits to nearest ERDDAP coordinates
   [~,ind] = min(abs(latitude - ymin));
   newLatIndex(1)=ind;
   [~,ind] = min(abs(latitude - ymax));
   newLatIndex(2)=ind;
   [~,ind] = min(abs(longitude- xmin));
   newLonIndex(1)=ind;
   [~,ind] = min(abs(longitude - xmax));
   newLonIndex(2)=ind;
   [~,ind] = min(abs(udtime- udtpos(i)));
   newTimeIndex(1)=ind;

   if(isequal(newLatIndex,oldLatIndex) & isequal(newLonIndex,oldLonIndex) && isequal(newTimeIndex(1),oldTimeIndex(1)));
     % the call will be the same as last time, so no need to repeat
     extract(i,:)=extractTemp;
   else
  %map request limits to nearest ERDDAP coordinates
     erddapLats= NaN(2,1);
     erddapLons= NaN(2,1);
     erddapTimes=cell(2,1);
     erddapLats(1)=latitude(newLatIndex(1));
     erddapLats(2)=latitude(newLatIndex(2));
     erddapLons(1)=longitude(newLonIndex(1));
     erddapLons(2)=longitude(newLonIndex(2));
     requesttime=isotime(newTimeIndex(1));
     erddapTimes(1)=requesttime;
     erddapTimes(2)=requesttime;
% build the erddap url
     myURL = buildURL(dataStruct,erddapLons,erddapLats,erddapTimes,urlbase);
     fileout='tmp.mat';
     downLoadReturn = getURL(myURL{1},fileout,dataStruct);
     paramExp=strcat('param=downLoadReturn.',dataStruct.varname);
     junk=evalc(paramExp);
     param=squeeze(param);
 %    [param, lon, lat, time]= getURL(myURL{1},fileout,dataStruct);
      % get array dimensions - note that the order of data returned is not the same   
      paramIndex=find(~isnan(param));
      extract(i,1) = mean(param(paramIndex));
      extract(i,2) = std(param(paramIndex));
      extract(i,3) = length(paramIndex);
      extract(i,4) = datenum8601(char(erddapTimes(1)));
      extract(i,5) = xmin;
      extract(i,6) = xmax;
      extract(i,7) = ymin;
      extract(i,8) = ymax;
      extract(i,9) = udtpos(i);
      extract(i,10) = median(param(paramIndex));
%      extract(i,11) = mad(param(paramIndex));
   end;
 end;
 extractStruct=struct('mean',extract(:,1),'std',extract(:,2),'nobs',extract(:,3), ...
      'extractTime',datestr(extract(:,4)),'lonmin',extract(:,5), ...
      'lonmax',extract(:,6),'latmin',extract(:,7),'latmax',extract(:,8), ...
      'requestTime',datestr(extract(:,9)),'median',extract(:,10),'mad',extract(:,11));

% fin
