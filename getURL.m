function [extract] = getURL(myURL,destfile,dataStruct)
     options = weboptions;
     options.Timeout = Inf;
    datasetname=dataStruct.datasetname;
    varname=dataStruct.varname;
    F=websave(destfile,myURL,options);
    extract=load(F);
%  remove extra layer of structure
    extract=eval(strcat('extract.',datasetname));
%remove altitude dimension
    junk=evalc(strcat('extract.',varname,'= squeeze(extract.',varname,')'));
