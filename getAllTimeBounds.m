function [erddapStruct] = getAllTimeBounds(erddapStruct,urlbase)
structLength=size(erddapStruct);
  for i = 3:structLength(1);
  i
%    myURL=strcat(urlbase,'minTime,maxTime,timeSpacing&datasetID="',erddapStruct(i,1).datasetname,'"');
%    myURL=strcat(urlbase,'minTime&datasetID="',erddapStruct(i,1).datasetname,'"');
    myURL=strcat(urlbase,'minTime,timeSpacing&datasetID="',erddapStruct(i,1).datasetname,'"');
    temp=webread(myURL);
    temp1=table2array(temp(2,1:2));
%    temp1=table2array(temp(2,1));
    erddapStruct(i,1).minTime=datenum8601(temp1{1});
%    erddapStruct(i,1).minTime=datenum8601(temp1{1});
%    erddapStruct(i,1).maxTime=datenum8601(temp1{2});
   erddapStruct(i,1).timeSpacing=str2num(temp1{2});
  end;


