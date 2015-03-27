% retrieve ETOPO Bathymetry Data in a Bounding Box
%
%  @keywords internal
%  \code{getETOPO} is an internal Function retrieve ETOPO Bathymetry Data in a
%       Bounding Box given by xpos, ypos
%
%  @param dataStruct A structure describing the dataset from erddapStruct.rda
%  @param xpos1 A list of reals size 2 of the longitude bounds
%  @param ypos A list of reals size 2 of the latitude bounds
%  @param verbose Logical variable if true will produce verbose
%     output from httr:GET
%  @param urlbase A character string giving the base URL of the ERDDAP server
%  @return Named Data array with data, or else NaN

function [extract, returnCode] = getETOPO(dataStruct,xpos1,ypos,urlbase)
options = weboptions;
options.Timeout = Inf;
returnCode=0;
xlim1 = min(xpos1);
xlim2 = max(xpos1);
ylim1 = min(ypos);
ylim2 = max(ypos);
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
if(returnCode == 0);
   myURL=strcat(urlbase,dataStruct.datasetname,'.csv?latitude[0:1:last]');
   temp=webread(myURL,options);
   temp1=table2array(temp(2:end,1));
   latitude=str2num(char(temp1));
   myURL=strcat(urlbase,dataStruct.datasetname,'.csv?longitude[0:1:last]');
   temp=webread(myURL,options);
   temp1=table2array(temp(2:end,1));
   longitude=str2num(char(temp1));
   [~,ind] = min(abs(latitude - ylim1));
   lat1=latitude(ind);
   [~,ind] = min(abs(latitude - ylim2));
   lat2=latitude(ind);
   [~,ind] = min(abs(longitude- xlim1));
   lon1=longitude(ind);
   [~,ind] = min(abs(longitude - xlim2));
   lon2=longitude(ind);
   fileout='tmpExtract.mat';
   myURL=strcat(urlbase,dataStruct.datasetname,'.mat?altitude', ...
              '[(',num2str(lat1),'):1:(',num2str(lat2),')]', ...
              '[(',num2str(lon1),'):1:(',num2str(lon2),')]');
    extract = getURL(myURL,fileout,dataStruct);
else
      disp('Error trying to retrive file, status');
      returnCode=-1;
end;
