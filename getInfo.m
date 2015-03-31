function [ ] = getInfo( dtype )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
urlbase1='http://coastwatch.pfeg.noaa.gov/erddap/tabledap/allDatasets.csv?';
load('erddapStruct.mat','erddapStruct');
structLength=size(erddapStruct);
dtypename=cell(structLength(1),1);
for i=1:structLength(1);
     dtypename{i}=erddapStruct(i,1).dtypename;
end;
if ischar(dtype);
  datatype = find(strcmp(dtypename,dtype), 1);
  if(isempty(datatype));
    disp('dataset name: ', dtype);
    disp('no matching dataset found');
    return;      
  end;
else
  datatype = dtype;
  if ((datatype < 1) || (datatype > structLength(1)));
    disp('dataset number out of range - must be between 1 and 107: ', datatype);
    disp('routine stops');
    return;
  end;
end
dataStruct = erddapStruct(datatype);
dataStruct = getMaxTime(dataStruct, urlbase1);
disp(dataStruct.minTime)
disp(dataStruct.maxTime)
dateBase= datenum('1970-01-01-00:00:00');
secsDay = 86400;
minTime = dataStruct.minTime;
minTime=(minTime/secsDay)+dateBase;
dataStruct.minTime=datestr(minTime,'yyyy-mm-dd');
maxTime = dataStruct.maxTime;
dataStruct.maxTime=datestr(maxTime,'yyyy-mm-dd');
dataStruct.timeSpacing = dataStruct.timeSpacing/secsDay;
disp(dataStruct);

end

