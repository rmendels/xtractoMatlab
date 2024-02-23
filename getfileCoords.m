function [isotime, udtime, altitude, latitude, longitude] = getfileCoords(info)
options = weboptions;
options.Timeout = Inf;
urlbase = info.access.urlBase;
% if time is a dimension,  get values
udtime = NaN;
isotime = NaN;
if (info.dimensions.time.exists)
    myURL=strcat(urlbase, 'griddap/', info.access.datasetID, '.csv?time[0:1:last]');
    temp=webread(myURL,options);
    temp1=table2array(temp(2:end, 1));
    timeLength = size(temp1);
    udtime = NaN(timeLength(1), 1);
    for i=1:timeLength(1)
       udtime(i) = datenum8601(temp1{i});
    end    
    isotime = temp1;
end
% get latitude values
myURL = strcat(urlbase, 'griddap/', info.access.datasetID, '.csv?latitude[0:1:last]');
temp = webread(myURL, options);
temp1 = table2array(temp(2:end, 1));
% latitude = str2num(char(temp1));
latitude = temp1;
myURL = strcat(urlbase, 'griddap/', info.access.datasetID, '.csv?longitude[0:1:last]');
temp = webread(myURL,options);
temp1 = table2array(temp(2:end, 1));
% longitude = str2num(char(temp1));
longitude = temp1;
if(info.dimensions.altitude.exists)
   myURL = strcat(urlbase, 'griddap/', info.access.datasetID, '.csv?altitude[0:1:last]');
   temp = webread(myURL, options);
   temp1 = table2array(temp(2:end, 1));
   altitude = str2double(char(temp1));
else
    altitude=NaN;
end
