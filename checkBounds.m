function [extract]=checkBounds(dataStruct,xposLim,yposLim,tposLim)
% check longitudes
extract=1;
if((xposLim(1) < dataStruct.minLongitude)  || (xposLim(2) > dataStruct.maxLongitude)) 
   disp('xpos  (longtude) has elements out of range of the dataset');
   disp('longtiude range in xpos');
   disp(strcat(num2str(xposLim(1)),' , ', num2str(xposLim(2))));
   disp  ('longitude range in ERDDAP data');
   disp(strcat(num2str(dataStruct.minLongitude),' , ', num2str(dataStruct.maxLongitude)));
   disp('execution stopped');
   extract=NaN;
end
% check latitudes
if((yposLim(1) < dataStruct.minLatitude)  || (yposLim(2) > dataStruct.maxLatitude)) 
   disp('ypos  (latitude) has elements out of range of the dataset');
   disp('latitiude range in ypos');
   disp(strcat(num2str(yposLim(1)),' , ', num2str(yposLim(2))));
   disp('latitude range in ERDDAP data');
   disp(strcat(num2str(dataStruct.minLatitude),' , ', num2str(dataStruct.maxLatitude)));
   disp('execution stopped');
   extract=NaN;
end 
% check time
if((tposLim(1) < dataStruct.minTime)  || (tposLim(2) > dataStruct.maxTime)) 
   disp('tpos  (time) has elements out of range of the dataset');
   disp('time range in tpos');
   disp(strcat(num2str(tposLim(1)),' , ', num2str(tposLim(2))));
   disp ('time range in ERDDAP data');
   disp(strcat(num2str(dataStruct.minTime),' , ', num2str(dataStruct.maxTime)));
   disp('execution stopped');
   extract=NaN;
end
