% retrieve ETOPO Bathymetry Data along a track
%
% @keywords internal
%  \code{getETOPOtrack}  is an internal Function retrieve ETOPO Bathymetry Data
%   in a Bounding Box given by xpos, ypos
%
%  @param dataStruct A structure describing the dataset from erddapStruct.rda
%  @param xpos1 A list of reals of the track longitudes
%  @param ypos A list of reals of the track latitude bounds
%  @param xrad A list of reals with distance around given longitude
%    to make extract
%  @param yrad A list of reals with distance around given latitude
%    to make extract
%  @param verbose Logical variable if true will produce verbose
%     output from httr:GET
%  @param urlbase A character string giving the base URL of the ERDDAP server
%  @return Named Data array with data, or else NaN

function [extractStruct, returnCode] =  getETOPOtrack(dataStruct,xpos1,ypos,xlen,ylen,urlbase)
options = weboptions;
options.Timeout = Inf;
returnCode=0;
xlim1=min(xpos1);
xlim2=max(xpos1);
ylim1=min(ypos);
ylim2=max(ypos);
extractTemp=ones(1,11)*NaN;     
% create arrays to store last indices of last call
oldLonIndex= int32(zeros(2,1));
oldLatIndex= int32(zeros(2,1));
oldTimeIndex=  int32(zeros(2,1));
newLonIndex= int32(zeros(2,1));
newLatIndex=  int32(zeros(2,1));
newTimeIndex=  int32(zeros(2,1));
extract=ones(length(xpos1),11)*NaN;     



if(strcmp(dataStruct.datasetname,'etopo360'));
   if((xlim1 < 0) || (xlim2 > 360)) ;
     disp('xpos  (longtude) has elements out of range of the dataset');
     disp('longtiude range in xpos');
     disp(strcat(xlim1,',', xlim2));
     returnCode= -1;
    end;
else 
   if((xlim1 < -180) || (xlim2 > 180));
     disp('xpos  (longtude) has elements out of range of the dataset');
     disp('longtiude range in xpos');
     disp(strcat(xlim1,',', xlim2));
     returnCode= -1;
   end;
end;
if((ylim1 < -90) || (ylim2 > 90));
    disp('ypos  (latitude) has elements out of range of the dataset');
    disp('latitude range in ypos');
    disp(strcat(ylim1,',', ylim2));
    returnCode= -1;
end;

if(returnCode == 0) ;
   myURL=strcat(urlbase,dataStruct.datasetname,'.csv?latitude[0:1:last]');
   temp=webread(myURL,options);
   temp1=table2array(temp(2:end,1));
   latitude=str2num(char(temp1));
   myURL=strcat(urlbase,dataStruct.datasetname,'.csv?longitude[0:1:last]');
   temp=webread(myURL,options);
   temp1=table2array(temp(2:end,1));
   longitude=str2num(char(temp1));
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
   for i = 1:length(xpos1);
      % define bounding box
      xmax=xpos1(i)+xrad(i)/2;
      xmin=xpos1(i)-xrad(i)/2;
      if(dataStruct.latSouth);
        ymax=ypos(i)+yrad(i)/2;
        ymin=ypos(i)-yrad(i)/2;
      else
        ymin=ypos(i)+yrad(i)/2;
        ymax=ypos(i)-yrad(i)/2;
      end;%rads
      %find closest time of available data
      %map request limits to nearest ERDDAP coordinates
      [~,ind] = min(abs(latitude - ymin));
      newLatIndex(1)=ind;
      [~,ind] = min(abs(latitude - ymax));
      newLatIndex(2)=ind;
      [~,ind] = min(abs(longitude- xmin));
     newLonIndex(1)=ind;
      [~,ind] = min(abs(longitude - xmax));
      newLonIndex(2)=ind;
      if(isequal(newLatIndex,oldLatIndex) & isequal(newLonIndex,oldLonIndex) && isequal(newTimeIndex(1),oldTimeIndex(1)));
        % the call will be the same as last time, so no need to repeat
         extract(i,:)=extractTemp;
      else
        erddapLats= NaN(2,1);
        erddapLons= NaN(2,1);
        erddapLats(1)=latitude(newLatIndex(1));
        erddapLats(2)=latitude(newLatIndex(2));
        erddapLons(1)=longitude(newLonIndex(1));
        erddapLons(2)=longitude(newLonIndex(2));
        myURL=strcat(urlbase,dataStruct.datasetname,'.mat?altitude', ...
                    '[(',num2str(erddapLats(1)),'):1:(',num2str(erddapLats(2)),')]', ...
                    '[(',num2str(erddapLons(1)),'):1:(',num2str(erddapLons(2)),')]');
        fileout='tmp.mat';
        downLoadReturn = getURL(myURL,fileout,dataStruct);
        paramExp=strcat('param=downLoadReturn.',dataStruct.varname);
        junk=evalc(paramExp);
        param=squeeze(param);
        param=double(param);
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
      end;
    end;%length
end;%return code
extractStruct=struct('mean',extract(:,1),'std',extract(:,2),'nobs',extract(:,3), ...
      'extractTime',extract(:,4),'lonmin',extract(:,5), ...
      'lonmax',extract(:,6),'latmin',extract(:,7),'latmax',extract(:,8), ...
      'requestTime',extract(:,9),'median',extract(:,10),'mad',extract(:,11));

