function [extract] = getURL(myURL,destfile,dataStruct)
    datasetname=dataStruct.datasetname;
    varname=dataStruct.varname;
    F=websave(destfile,myURL);
    extract=load(F);
%  remove extra layer of structure
    extract=eval(strcat('extract.',datasetname));
%remove altitude dimension
    junk=evalc(strcat('extract.',varname,'= squeeze(extract.',varname,')'));
