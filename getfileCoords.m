function [coordinate_info] = getfileCoords(info)
    options = weboptions;
    options.Timeout = Inf;
    urlbase = info.access.urlBase;
    %  loop over dimensions
    no_dims = size(info.dimensions, 2);
    names = arrayfun(@(x) x.name{1}, info.dimensions, 'UniformOutput', false);
    coordinate_info(no_dims) = struct('name', '',  'values', '');
    
    for i = 1:size(info.dimensions, 2)
        datasetID = info.access.datasetID;
        dim_name = info.dimensions(i).name{1};
        myURL=strcat(urlbase, 'griddap/', datasetID, '.csv?', dim_name, '[0:1:last]');
        temp=webread(myURL,options);
        temp1=table2array(temp(2:end, 1));
        
        if (strcmp(info.dimensions(i).name, 'time'))
            timeLength = size(temp1);
            %udtime = NaN(timeLength(1), 1);
            %for itime = 1:timeLength(1)
            %   udtime(itime) = datenum8601(temp1{itime});
            %end
            %udtime(itime) = erddap8601(temp1{itime});  
            isotime = temp1;
            coordinate_info(i).name = 'time';
            coordinate_info(i).values = isotime';
        else
            coordinate_info(i).values = temp1';  
            coordinate_info(i).name = names(i)';  
        end
    end
end

