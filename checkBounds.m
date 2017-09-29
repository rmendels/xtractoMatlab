function [extract] = checkBounds(info, tposLim, yposLim, xposLim)
% check longitudes
extract=1;
if((xposLim(1) < info.dimensions.longitude.min)  || (xposLim(2) > info.dimensions.longitude.max)) 
   disp('xpos  (longtude) has elements out of range of the dataset');
   disp('longtiude range in xpos');
   disp(strcat(num2str(xposLim(1)),' , ', num2str(xposLim(2))));
   disp  ('longitude range in ERDDAP data');
   disp(strcat(num2str(info.dimensions.longitude.min),' , ', num2str(info.dimensions.longitude.max)));
   disp('execution stopped');
   extract=NaN;
end
% check latitudes
% need to clean up for north to south datasets
if (info.dimensions.latitude.lat_south)
    min_lat = info.dimensions.latitude.min;
    max_lat = info.dimensions.latitude.max;
else
    min_lat = info.dimensions.latitude.max;
    max_lat = info.dimensions.latitude.min;
end    
if((yposLim(1) < min_lat)  || (yposLim(2) > max_lat)) 
   disp('ypos  (latitude) has elements out of range of the dataset');
   disp('latitiude range in ypos');
   disp(strcat(num2str(yposLim(1)),' , ', num2str(yposLim(2))));
   disp('latitude range in ERDDAP data');
   disp(strcat(num2str(info.dimensions.latitude.min),' , ', num2str(info.dimensions.latitude.max)));
   disp('execution stopped');
   extract = NaN;
end 
% check time
if (info.dimensions.time.exists)
    minTime = datenum8601(info.dimensions.time.min);
    maxTime = datenum8601(info.dimensions.time.max);
    if((tposLim(1) < minTime)  || (tposLim(2) > maxTime)) 
       disp('tpos  (time) has elements out of range of the dataset');
       disp('time range in tpos');
       disp(strcat(num2str(tposLim(1)),' , ', num2str(tposLim(2))));
       disp ('time range in ERDDAP data');
       disp(strcat(info.dimensions.time.min,' , ', info.dimensions.time.max));
       disp('execution stopped');
       extract = NaN;
    end
end

