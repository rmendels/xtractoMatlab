function [extract] = getURL(info, myURL, destfile)
     options = weboptions;
     options.Timeout = Inf;
     datasetname = info.access.datasetID;
     F = websave(destfile, myURL, options);
     extract = load(F);
%  remove extra layer of structure
    extract = eval(strcat('extract.', datasetname));
%remove altitude dimension
    f_names = fieldnames(extract);
    extract_parameter = f_names{end,:};
    junk = evalc(strcat('extract.', extract_parameter, '= squeeze(extract.', extract_parameter,')'));
