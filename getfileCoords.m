function [isotime,udtime,latitude,longitude, altitude]=getfileCoords(dataStruct, urlbase)
options = weboptions;
options.Timeout = Inf;
hasAltitude=dataStruct.hasAlt;
myURL=strcat(urlbase,dataStruct.datasetname,'.csv?time[0:1:last]');
temp=webread(myURL,options);
temp1=table2array(temp(2:end,1));
timeLength=size(temp1);
udtime=NaN(timeLength(1),1);
for i=1:timeLength(1);
   udtime(i)=datenum8601(temp1{i});
end;
isotime=temp1;
myURL=strcat(urlbase,dataStruct.datasetname,'.csv?latitude[0:1:last]');
temp=webread(myURL,options);
temp1=table2array(temp(2:end,1));
latitude=str2num(char(temp1));
myURL=strcat(urlbase,dataStruct.datasetname,'.csv?longitude[0:1:last]');
temp=webread(myURL,options);
temp1=table2array(temp(2:end,1));
longitude=str2num(char(temp1));
if(hasAltitude);
   myURL=strcat(urlbase,dataStruct.datasetname,'.csv?altitude[0:1:last]');
   temp=webread(myURL,options);
   temp1=table2array(temp(2:end,1));
   altitude=str2num(char(temp1));
else
    altitude=NaN;
end;
