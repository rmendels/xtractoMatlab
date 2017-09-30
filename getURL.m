function [extract] = getURL(info, myURL, destfile)
     options = weboptions;
     options.Timeout = Inf;
     datasetname = info.access.datasetID;
     F = websave(destfile, myURL, options);
     extract = load(F);
%  remove extra layer of structure
    extract = eval(strcat('extract.', datasetname));
%  Matlab likes doubles
    extract.longitude = double(extract.longitude);
    extract.latitude = double(extract.latitude);
    f_names = fieldnames(extract);
    extract_parameter = f_names{end,:};
    extract.(extract_parameter) = double(extract.(extract_parameter));

   
