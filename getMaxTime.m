function [dataStruct] = getMaxTime(dataStruct,urlbase)
options = weboptions;
options.Timeout = Inf;
options.ContentType = 'json';
options.ArrayFormat = 'json';
structLength=size(dataStruct);
myURL=strcat(urlbase,'maxTime&datasetID="',dataStruct.datasetname,'"');
temp=webread(myURL,options);
temp1=temp.table.rows{1};
dataStruct.maxTime=datenum8601(temp1{1});

