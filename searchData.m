function [ ] = searchData( searchList )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
urlbase1='http://coastwatch.pfeg.noaa.gov/erddap/tabledap/allDatasets.csv?';
dateBase= datenum('1970-01-01-00:00:00');
secsDay = 86400;
if(~iscellstr(searchList));
    error('searchList must be a cell-array');
end;
if(size(searchList,2) ~= 2);
    error('searchList must be of size nx2');
end;
load('erddapStruct.mat','erddapStruct');

myList{1} = 'dtypename';
myList{2} = 'datasetname';
myList{3} = 'longname';
myList{4} = 'varname';

listLen = size(searchList,1);
dataStruct = erddapStruct;
for i = 1:listLen;
   structLength=size(dataStruct);
   dtypename=cell(structLength(1),1);
   datasetname=cell(structLength(1),1);
   longname=cell(structLength(1),1);
   varname=cell(structLength(1),1);
   for j=1:structLength(1);
     dtypename{j}=dataStruct(j,1).dtypename;
     datasetname{j}=dataStruct(j,1).datasetname;
     longname{j}=dataStruct(j,1).longname;
     varname{j}=dataStruct(j,1).varname;
  end;
   requestType = searchList{i,1};
   requestString = searchList{i,2};
   inList = strcmp(myList,requestType);
   if(sum(inList) == 0);
      disp('requestType must be one of:');
      disp('dtypename,datasetname,longname,varname');
      error(strcat('you requested :', requestType));
   end;
   q = char(39);
   newrequestString=strcat(q,requestString,q);
   request = strcat('myIndex=strfind(',requestType,',',newrequestString,')');
   junk = evalc(request);
   newIndex=zeros(size(myIndex,1));
   for i = 1:size(myIndex,1);
       if(size(myIndex{i},1) == 0);
           newIndex(i)=0;
       else
           newIndex(i)=1;
       end;
   end;
   dataStruct=dataStruct(newIndex==1);
end;
structLength=size(dataStruct,1);
for i= 1:structLength;
    tempStruct=dataStruct(i);
    tempStruct=getMaxTime(tempStruct,urlbase1);
    tempStruct.minTime=(tempStruct.minTime/secsDay)+dateBase;
    tempStruct.minTime=datestr(tempStruct.minTime,'yyyy-mm-dd');
    tempStruct.maxTime=datestr(tempStruct.maxTime,'yyyy-mm-dd');
    tempStruct.timeSpacing = tempStruct.timeSpacing/secsDay;
    disp(tempStruct);
end;

end

