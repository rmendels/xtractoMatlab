function [extract] = getURL(datasetInfo, myURL, destfile)
     options = weboptions;
     options.Timeout = Inf;
     datasetID = datasetInfo.access.datasetID;
     F = websave(destfile, myURL, options);
     extract = load(F);
%  remove extra layer of structure
    extract = extract.(datasetID);
%  Matlab likes doubles
    f_names = fieldnames(extract); 
    for i = 1:(numel(f_names))
        if (~strcmp('time', f_names(i)))
            extract.(f_names{i}) = double(extract.(f_names{i}));
        end
    end
% changed time to iso time if time is there
    time_dim = find(strcmp('time', f_names));
    if (~isempty(time_dim))
       extract.time =  string(secondsToISO(extract.time));
    end
end
   
