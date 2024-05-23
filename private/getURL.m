function [extract] = getURL(datasetInfo, myURL, destfile)
%
%  Function to call ERDDAP URL and read results into Workspace
%
% INPUTS:
%       datasetInfo - output from calling erddapInfo()
%       myURL - ERDDAP URL from buildURL()
%       destfile - where to save the downloaded Matlag file
%
% OUTPUTS:
%        extract - structure containing all the coordinates plus the extracted data.
%

     options = weboptions;
     options.Timeout = Inf;
     datasetID = datasetInfo.access.datasetID;
     F = websave(destfile, myURL, options);
     extract = load(F);
%  remove extra layer of structure
    tempName = string(fieldnames(extract));
    extract = extract.(tempName);
%  Matlab likes doubles
    f_names = string(fieldnames(extract)); 
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
   
