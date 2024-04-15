function [coordinate_info] = getfileCoords(datasetInfo)
    options = weboptions;
    options.Timeout = Inf;
    urlbase = datasetInfo.access.urlBase;
    %  loop over dimensions
    no_dims = numel(datasetInfo.dimensionNames);
    %names = arrayfun(@(x) x.name{1}, datasetInfo.dimensions, 'UniformOutput', false);
    %coordinate_info(no_dims) = struct('name', '',  'values', '');
    datasetID = datasetInfo.access.datasetID;
    for i = 1:no_dims
        dim_name = datasetInfo.dimensionNames(i);
        myURL=strcat(urlbase, 'griddap/', datasetID, '.csv?', dim_name, '[0:1:last]');
        temp=webread(myURL,options);
        temp1=table2array(temp(1:end, 1));
        
        if (strcmp(dim_name, 'time'))
            timeLength = size(temp1);
            %udtime = NaN(timeLength(1), 1);
            %for itime = 1:timeLength(1)
            %   udtime(itime) = datenum8601(temp1{itime});
            %end
            %udtime(itime) = erddap8601(temp1{itime});  
            isotime = temp1;
            coordinate_info.('time') = isotime';
            %coordinate_info(i).name = 'time';
            %coordinate_info(i).values = isotime';
        else
            coordinate_info.(dim_name) = temp1';  
        end
    end
end

