function [dataStruct] = getMaxTime(dataStruct,urlbase)
options = weboptions;
options.Timeout = Inf;
structLength=size(dataStruct);
myURL=strcat(urlbase,'maxTime&datasetID="',dataStruct.datasetname,'"');
temp=webread(myURL,options);
temp1=table2array(temp(2,1));
dataStruct.maxTime=datenum8601(temp1{1});


