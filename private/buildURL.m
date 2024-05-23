function myURL = buildURL(datasetInfo,  parameter, erddapCoords)
% Internal function to take the dataset info and the requested coordinates
% and build the URL to make an ERDDAP request.
%
% INPUTS:  
%    datasetInfo:  result of calling erddapInfo.m
%    parameter: name of parameter to extract
%    erddapCoords: ERDDAP dimension constraints generated by
%    xtracto.m, xtracto_3D.m, and xtractogon.m
% 
% OUTPUTS: 
%    ERDDAP URL
%
    urlbase = datasetInfo.access.urlBase;
    datasetID = datasetInfo.access.datasetID;
    datasetDim = datasetInfo.dimensionNames;
    %varname = datasetInfo.variables;
    varname = parameter;
    myURL=strcat(urlbase, 'griddap/', datasetID, '.mat?', varname);
    %callDimsNames  = fieldnames(erddapCoords);
     % Loop through each field of the structure
    for i = 1:numel(datasetDim)
        % find name of  dimension  i in datasett
        dimName = datasetDim(i);
        values = erddapCoords.(dimName);
        if strcmp(dimName{1}, 'time')
            formattedStr = strcat('[(', values{1}, '):1:(', values{2}, ')]');
        else 
            if(~isempty(values))
                value1 = num2str(values(1));
                value2 = num2str(values(2));
                formattedStr = strcat('[(', value1, '):1:(' , value2, ')]');
            end
        end
        myURL = strcat(myURL, formattedStr);
    end
end